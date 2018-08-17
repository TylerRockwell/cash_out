describe CashOut::Payments::Customer::Delete do
  subject { described_class.run(service_params) }

  let(:user) { User.new(stripe_id: 'test_cus_123') }
  let(:service_params) { { user: user } }

  it "deletes a customer for the user" do
    subject
    expect(user.stripe_id).to be nil
  end
end
