# frozen_string_literal: true

class DocumentsController < ApplicationController
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

  def document_params
    params.require(:document).permit(%i[file])
  end
end
