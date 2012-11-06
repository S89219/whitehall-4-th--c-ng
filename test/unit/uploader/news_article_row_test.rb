# encoding: UTF-8
# *NOTE* this file deliberately does not include test_helper
# in order to attempt to speed up the tests

require 'active_support/test_case'
require 'minitest/autorun'

require 'whitehall/uploader/news_article_row'
require 'logger'

module Whitehall::Uploader
  class NewsArticleRowTest < ActiveSupport::TestCase
    def news_article_row(data)
      NewsArticleRow.new(data, 1)
    end

    test "takes legacy url from the old_url column" do
      row = news_article_row("old_url" => "http://example.com/old-url")
      assert_equal "http://example.com/old-url", row.legacy_url
    end

    test "takes title from title column" do
      row = news_article_row("title" => "a-title")
      assert_equal "a-title", row.title
    end

    test "takes summary from the summary column, converting relative links to absolute" do
      Parsers::RelativeToAbsoluteLinks.stubs(:parse).with("relative links", "url").returns("absolute links")
      row = news_article_row("summary" => "relative links")
      row.stubs(:organisation).returns(stub("organisation", url: "url"))
      assert_equal "absolute links", row.summary
    end

    test "takes body from the 'body' column, converting relative links to absolute" do
      Parsers::RelativeToAbsoluteLinks.stubs(:parse).with("relative links", "url").returns("absolute links")
      row = news_article_row("body" => "relative links")
      row.stubs(:organisation).returns(stub("organisation", url: "url"))
      assert_equal "absolute links", row.body
    end

    test "finds an organisation using the organisation finder" do
      organisation = stub("Organisation")
      Finders::OrganisationFinder.stubs(:find).with("name or slug", anything, anything).returns([organisation])
      row = news_article_row("organisation" => "name or slug")
      assert_equal organisation, row.organisation
    end

    test "takes first_published_at from the 'first_published' column" do
      Parsers::DateParser.stubs(:parse).with("first-published-date", anything, anything).returns("date-object")
      row = news_article_row("first_published" => "first-published-date")
      assert_equal "date-object", row.first_published_at
    end

    test "finds related policies using the policy finder" do
      policies = 5.times.map { stub('policy') }
      Finders::PoliciesFinder.stubs(:find).with("first", "second", "third", "fourth", anything, anything).returns(policies)
      row = news_article_row("policy_1" => "first", "policy_2" => "second", "policy_3" => "third", "policy_4" => "fourth")
      assert_equal policies, row.related_policies
    end

    test "finds the roles ministers in minister_1 and minister_2 columns held on the publication date" do
      appointments = 2.times.map { stub('appointment') }
      first_published_at = stub('first-published-at')
      Finders::RoleAppointmentsFinder.stubs(:find).with(first_published_at, "minister-1", "minister-2", anything, anything).returns(appointments)
      row = news_article_row("minister_1" => "minister-1", "minister_2" => "minister-2")
      row.stubs(:first_published_at).returns(first_published_at)
      assert_equal appointments, row.role_appointments
    end

    test "supplies an attribute list for the new news article record" do
      row = news_article_row({})
      attribute_keys = [:title, :summary, :body, :organisations, :first_published_at, :related_policies, :role_appointments]
      attribute_keys.each do |key|
        row.stubs(key).returns(key.to_s)
      end
      expected_attributes = attribute_keys.each.with_object({}) {|key, hash| hash[key] = key.to_s }
      assert_equal expected_attributes, row.attributes
    end
  end
end
