require 'spec_helper'

describe "snapshots/edit" do
  before(:each) do
    @snapshot = assign(:snapshot, stub_model(Snapshot,
      :user => nil,
      :snapshot_code => "MyString",
      :snapshot_notes => "MyText"
    ))
  end

  it "renders the edit snapshot form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", snapshot_path(@snapshot), "post" do
      assert_select "input#snapshot_user[name=?]", "snapshot[user]"
      assert_select "input#snapshot_snapshot_code[name=?]", "snapshot[snapshot_code]"
      assert_select "textarea#snapshot_snapshot_notes[name=?]", "snapshot[snapshot_notes]"
    end
  end
end
