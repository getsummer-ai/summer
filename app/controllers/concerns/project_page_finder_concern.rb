# frozen_string_literal: true
module ProjectPageFinderConcern
  def find_project_page
    pages_query = current_project.pages
    condition =
      (
        if params[:page_id].to_s.length == 32
          { url_hash: params[:page_id] }
        else
          { id: BasicEncrypting.decode(params[:page_id]) }
        end
      )
    @project_page = pages_query.find_by!(condition)
  end
end
