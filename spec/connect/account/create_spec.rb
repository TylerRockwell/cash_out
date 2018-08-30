describe CashOut::Connect::Account::Create do
  let(:user) { User.new }
  let(:terms_accepted) { true }

  subject { described_class.run(service_params) }

  let(:terms_accepted) { true }
  let(:service_params) do
    {
      user: user,
      ip_address: "127.0.0.1",
      legal_entity_type: "individual",
      ssn_last_4: "0000",
      stripe_terms_accepted: terms_accepted,
      legal_entity_address: {
        line1: "123 Fake St.",
        line2: "Apt 5B",
        city: "New York",
        state: "NY",
        country: "US",
        postal_code: "10108"
      },
      external_account_token: "stripe_account_token"
    }
  end

  before do
    StripeMock.start
    service_params[:legal_entity_address][:line2] = ""
  end

  after { StripeMock.stop }

  it_behaves_like 'a valid service run'

  it "creates a managed account for the user" do
    subject
    expect(user.stripe_id).to match("test_acct_")
  end

  context "with a nil value for optional attribute line2" do
    before do
      service_params[:legal_entity_address][:line2] = nil
    end

    it "creates a managed account for the user" do
      subject
      expect(user.stripe_id).to match("test_acct_")
    end
  end

  context "account creation fails" do
    let(:error) { Stripe::InvalidRequestError.new("Bad things", "") }
    before { StripeMock.prepare_error(error, :new_account) }

    it_behaves_like "an invalid service run with errors", [:stripe], "Bad things"
  end

  context "validations" do
    context "terms not accepted" do
      let(:terms_accepted) { false }
      it_behaves_like "an invalid service run with errors",
                      [:stripe_terms_accepted],
                      "can't be blank"
    end

    context "account already exists" do
      before { user.update(stripe_id: "12345") }
      it_behaves_like "an invalid service run with errors",
                      [:stripe],
                      I18n.t('cash_out.connect.account_already_exists')
    end

    context "legal_entity_address with empty strings" do
      before do
        service_params[:legal_entity_address][:line1] = ""
        service_params[:legal_entity_address][:city] = ""
        service_params[:legal_entity_address][:state] = ""
        service_params[:legal_entity_address][:postal_code] = ""
        service_params[:legal_entity_address][:country] = ""
      end

      it_behaves_like "an invalid service run with errors",
                      %i(line1 city state postal_code country),
                      "is required"
    end
  end
end

