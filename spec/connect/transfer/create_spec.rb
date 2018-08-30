describe CashOut::Connect::Transfer::Create do
  let(:payee) { User.new(stripe_id: 'acct_1234') }
  let(:platform_stripe_account) { 'acct_platform' }
  let(:amount_to_payout) { 300 }
  let(:service_params) { { payee: payee, amount_to_payout: amount_to_payout } }

  let(:transfer_params) do
    [
      {
        amount: amount_to_payout.abs,
        currency: "usd",
        description: "",
        destination: recipient
      },
      {
        stripe_account: sender
      }
    ]
  end

  subject { described_class.run(service_params) }

  before { StripeMock.start }
  after { StripeMock.stop }

  context "transfer is successful" do
    before do
      allow(Stripe::Account).to receive(:retrieve)
        .and_return(double(:account, id: platform_stripe_account))
    end

    context "negative payout" do
      let(:recipient) { platform_stripe_account }
      let(:sender) { payee.stripe_id }
      let(:amount_to_payout) { -300 }

      it "transfers to the platform account" do
        expect(Stripe::Transfer).to receive(:create).with(*transfer_params)
        subject
      end
    end

    context "positive payout" do
      # Occurs when charges < payout
      let(:recipient) { payee.stripe_id }
      let(:sender) { platform_stripe_account }
      let(:amount_to_payout) { 300 }

      it "transfers to the payee" do
        expect(Stripe::Transfer).to receive(:create).with(*transfer_params)
        subject
      end
    end
  end

  context "Stripe error occurs" do
    let(:error) { Stripe::InvalidRequestError.new("Bad things", "") }

    before { StripeMock.prepare_error(error, :new_transfer) }

    it_behaves_like "an invalid service run with errors", [:stripe], "Bad things"
  end
end
