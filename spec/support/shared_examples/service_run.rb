shared_examples "a valid service run" do
  it "succeeds" do
    expect(subject).to be_valid
  end
end

shared_examples "a valid service run with object creation" do |value, count|
  it_behaves_like "a valid service run"

  it "creates new object(s)" do
    expect { subject }.to change { value.constantize.count }.by(count)
  end
end

shared_examples "a valid service run with object destruction" do |value, count|
  it_behaves_like "a valid service run with object creation", value, (-1 * count.abs)
end

shared_examples "an invalid service run with errors" do |keys, message|
  it "fails" do
    expect(subject).to_not be_valid
  end

  it "returns errors" do
    expect(subject.errors.messages).to include(
      keys.map do |val|
        { "#{val}": [message] }
      end.first
    )
  end
end
