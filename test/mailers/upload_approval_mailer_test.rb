require 'test_helper'

class UploadApprovalMailerTest < ActionMailer::TestCase
  test "approve" do
    mail = UploadApprovalMailer.approve
    assert_equal "Approve", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
