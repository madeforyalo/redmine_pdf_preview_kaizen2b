# frozen_string_literal: true
RedmineApp::Application.routes.draw do
  scope module: 'redmine_pdf_preview_kaizen2b', as: 'redmine_pdf_preview_kaizen2b' do
    # ya existentes (visor PDF)
    get 'pdf_preview/:id',      to: 'viewer#show', as: :viewer
    get 'pdf_preview/:id/file', to: 'viewer#file', as: :file

    # NUEVAS (office -> pdf -> viewer)
    get 'office_preview/:id',      to: 'office#show', as: :office_preview
    get 'office_preview/:id/file', to: 'office#file', as: :office_file
  end
end
