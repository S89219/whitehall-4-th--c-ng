module PreviewUrlHelper

  def edition_preview_url(edition)
    return unless edition.base_path

    host = Plek.new.external_url_for("draft-origin")
    params = { token: edition.auth_bypass_token }.to_query
    "#{host}#{edition.base_path}?#{params}"
  end
end
