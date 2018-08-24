describe CashOut::Charge::Create do
  subject { described_class.run(service_params) }

  let(:payor) { User.new(stripe_id: 'cus_1234') }
  let(:payee) { User.new(stripe_id: 'acct_5678') }

  let(:service_params) do
    {
      amount_to_charge: amount_to_charge,
      amount_to_payout: amount_to_payout,
      payor: payor,
      payee: payee
    }
  end

  let(:destination_charge_params) do
    {
      amount: amount_to_charge,
      currency: "usd",
      description: "",
      customer: payor.stripe_id,
      destination: {
        account: payee.stripe_id,
        amount: amount_to_payout
      }
    }
  end

  let(:standalone_charge_params) do
    {
      amount: amount_to_charge,
      currency: "usd",
      description: "",
      customer: payor.stripe_id,
      transfer_group: ""
    }
  end

  let(:amount_to_charge) { 3_000 }
  let(:amount_to_payout) { nil }

  before { StripeMock.start }

  after { StripeMock.stop }

  context "when charge is successful" do
    context "when payout is positive" do
      let(:amount_to_payout) { 300 }

      it "charges the requestor" do
        expect(Stripe::Charge).to receive(:create).with(destination_charge_params)
        subject
      end
    end

    context "when payout is negative" do
      let(:amount_to_charge) { 3_000 }
      let(:amount_to_payout) { -300 }

      it "charges the requestor" do
        expect(Stripe::Charge).to receive(:create).with(standalone_charge_params)
        subject
      end

      it "initiates a transfer" do
        expect(CashOut::Connect::Transfer::Create).to receive(:run)
        subject
      end
    end
  end

  context "when charge is declined" do
    before { StripeMock.prepare_card_error(:card_declined) }

    it_behaves_like "an invalid service run with errors",
                    [:stripe],
                    "(Status 402) The card was declined"
  end

  context "when a Stripe error occurs" do
    let(:failure_message) { { stripe: ["Bad things"] } }

    before do
      allow(Stripe::Charge).to receive(:create)
        .and_raise(Stripe::InvalidRequestError.new("Bad things", ""))
    end

    it_behaves_like "an invalid service run with errors", [:stripe], "Bad things"
  end
end


