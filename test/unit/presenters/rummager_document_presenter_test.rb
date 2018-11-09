require 'test_helper'

class RummagerDocumentPresenterTest < ActiveSupport::TestCase
  def rummager_result
    {
      "link" => "/government/news/quiddich-world-cup-2018",
      "title" => "Quiddich World Cup 2018",
      "description" => "The Quiddich World Cup 2018 will be...",
      "public_timestamp" => "2018-10-25T10:18:32Z",
      "display_type" => "News story",
      "document_collections" => [
        {
          "title" => "Wizarding sports",
          "link" => "/government/collections/wizarding-sports"
        },
        {
          "title" => "Guidance for hosting wizarding competitions",
          "link" => "/government/collections/guidance-for-hosting-wizarding-competitions"
        },
      ],
    }
  end

  def presenter
    RummagerDocumentPresenter.new rummager_result
  end

  test "will provide access to document attributes required for Finders and Lists" do
    assert_equal rummager_result['title'], presenter.title
    assert_equal rummager_result['link'], presenter.link
    assert_equal rummager_result['display_type'], presenter.display_type_key
  end

  test "will produce a humanized publication date required by Finders and Lists" do
    assert_equal presenter.publication_date, '25 October 2018'
  end

  test "will returns associated document collections" do
    expected_result = "Part of a collection: <a href=\"https://www.test.gov.uk/government/collections/wizarding-sports\">" +
      "Wizarding sports</a> and <a href=\"https://www.test.gov.uk/government/collections/guidance-for-hosting-wizarding-competitions\">" +
      "Guidance for hosting wizarding competitions</a>"
    assert_equal expected_result, presenter.publication_collections
  end
end
