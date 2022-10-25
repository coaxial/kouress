# frozen_string_literal: true

class DocumentsController < ApplicationController
  before_action :reject_unsupported_mimetypes, only: :create

  def new
    @document = Document.new
  end

  def create
    file = document_params[:file]
    size_bytes = file.size
    original_filename = file.original_filename
    mimetype = file.content_type
    @document = Document.new(document_params.merge(size_bytes:, original_filename:, mimetype:))
    if @document.save
      redirect_to documents_path, notice: t('.success')
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def index
    @documents = Document.all
  end

  private

  def reject_unsupported_mimetypes
    Rails.logger.debug { "entering reject_unsupported_mimetypes with #{document_params}" }
    unless Document.supported_mimetypes.include?(document_params[:file].content_type)
      Rails.logger.debug 'rejecting mimetype'
      # TODO: show list of supported documents along with error message
      flash.now.alert = t('documents.create.unsupported_mimetype')
      @document = Document.new
      render 'new', status: :unprocessable_entity
    end
    Rails.logger.debug 'accepting mimetype'
  end

  def document_params
    params.require(:document).permit(%i[file])
  end
end
