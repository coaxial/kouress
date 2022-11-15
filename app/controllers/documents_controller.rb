# frozen_string_literal: true

class DocumentsController < ApplicationController
  before_action :reject_unsupported_mimetypes, only: :create

  def index
    # TODO: paginate this
    @documents = Document.all
  end

  def new
    @document = Document.new
  end

  def create
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

  def reject_unsupported_mimetypes
    unless Document.supported_mimetypes.include?(
      document_params[:file].content_type
    )
      @document = Document.new(create_params)
      flash.now.alert = t('documents.create.unsupported_mimetype')
      render 'new', status: :unprocessable_entity
    end
  end

  def document_params
    params.require(:document).permit(%i[file])
  end

  def create_params
    document_params.merge(
      size_bytes: document_params[:file].size,
      original_filename: document_params[:file].original_filename,
      mimetype: document_params[:file].content_type
    )
  end
end
