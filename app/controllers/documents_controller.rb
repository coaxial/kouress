# frozen_string_literal: true

class DocumentsController < ApplicationController
  before_action :reject_unsupported_mimetypes, only: :create

  def index
    @documents = []
    if params[:query]
      search_for_matches
    else
      @documents = Document.all
    end
    @documents = @documents.order(updated_at: :desc).kpage(params[:kpage]) unless @documents.empty?
  end

  def new
    @document = Document.new
    @languages = Language.all.sort_by(&:fulltext_name)
  end

  def create
    @languages = Language.all.sort_by(&:fulltext_name)
    @document = Document.new(create_params)
    if @document.save
      redirect_back_or_to documents_path, notice: t('.success')
    else
      flash.now.alert = t('.failure')
      render 'new', status: :unprocessable_entity
    end
  end

  def show
    @document = Document.find(params[:id])
    @pages = @document.pages.order(:page_num).kpage(params[:kpage]).per(5)
  end

  def destroy
    @document = Document.find(params[:id])
    if @document.destroy
      redirect_back_or_to root_path, notice: t('.success')
    else
      flash.now[:alert] = t('.failure')
      render 'index', status: :unprocessable_entity
    end
  end

  private

  def search_for_matches
    # There will be duplicates, from page matches (i.e. multiple pages in the
    # same document) so filter out duplicate document_ids before loading them.
    matching_document_ids = PgSearch.multisearch(params[:query]).map(&:document_id).uniq
    # .find(Array) returns an Array instead of an ActiveRecord::Relation which
    # breaks the rest of the controller because it's lacking things like
    # #order, #kpage, etc.
    @documents = Document.where(id: matching_document_ids)
  end

  def reject_unsupported_mimetypes
    unless Document.supported_mimetypes.include?(
      document_params[:file].content_type,
    )
      @languages = Language.all.sort_by(&:fulltext_name)
      @document = Document.new(create_params)
      flash.now.alert = t('documents.create.unsupported_mimetype')
      render 'new', status: :unprocessable_entity
    end
  end

  def document_params
    params.require(:document).permit(%i[file language])
  end

  def create_params
    document_params.merge(
      size_bytes: document_params[:file].size,
      original_filename: document_params[:file].original_filename,
      mimetype: document_params[:file].content_type,
      language: Language.find(document_params[:language]),
    )
  end
end
