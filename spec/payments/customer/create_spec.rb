RSpec.describe CashOut::Payments::Customer::Create do
  subject { described_class.run(service_params) }

  let(:stripe_helper) { StripeMock.create_test_helper }
  let(:user) { User.new(stripe_id: nil) }
  let(:service_params) do
    { stripe_token: stripe_helper.generate_card_token, user: user }
  end

  before { StripeMock.start }

  after { StripeMock.stop }

  it "creates a customer account for the user" do
    subject
    # Value comes from Stripe Ruby Mock
    expect(user.stripe_id).to match("test_cus")
  end

  context "when account creation fails" do
    context "when the request is invalid" do
      let(:error) { Stripe::InvalidRequestError.new("Bad things", "") }
      before { StripeMock.prepare_error(error, :new_customer) }

      it_behaves_like "an invalid service run with errors", [:stripe], "Bad things"
    end

    context "with card error" do
      before { StripeMock.prepare_card_error(:invalid_cvc, :new_customer) }

      it_behaves_like "an invalid service run with errors",
                      [:stripe],
                      I18n.t('cash_out.customer.invalid_card')
    end
  end

  context "with validations" do
    context "when account already exists" do
      before { user.update(stripe_id: "12345") }

      let(:failure_message) { { stripe: ["Account already exists"] } }

      it_behaves_like "an invalid service run with errors",
                      [:stripe],
                      I18n.t('cash_out.customer.account_already_exists')
    end
  end
end
