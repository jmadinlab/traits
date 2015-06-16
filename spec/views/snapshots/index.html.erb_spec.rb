require 'spec_helper'

describe "snapshots/index" do
  before(:each) do
    assign(:snapshots, [
      stub_model(Snapshot,
        :user => nil,
        :snapshot_code => "Snapshot Code",
        :snapshot_notes => "MyText"
      ),
      stub_model(Snapshot,
        :user => nil,
        :snapshot_code => "Snapshot Code",
        :snapshot_notes => "MyText"
      )
    ])
  end

  it "renders a list of snapshots" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Snapshot Code".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
