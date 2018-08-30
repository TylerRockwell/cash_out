describe CashOut::Connect::Account::Delete do
  let(:user) { User.new(stripe_id: 'acct_1234') }

  subject { described_class.run(user: user) }

  let(:account_double) { double(:account, delete: true) }

  before do
    allow(Stripe::Account).to receive(:retrieve)
      .with(user.stripe_id)
      .and_return(account_double)
  end

  it_behaves_like 'a valid service run'

  it "deletes a managed account for the user" do
    subject
    expect(user.stripe_id).to be nil
  end
end

