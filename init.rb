# frozen_string_literal: true
require_relative 'lib/redmine_pdf_preview_kaizen2b/engine'

Redmine::Plugin.register :redmine_pdf_preview_kaizen2b do
  name        'Redmine PDF Preview KaiZen2B'
  author      'KaiZen2B'
  description 'Inline PDF preview in Redmine using PDF.js'
  version     '1.0.0'
  url         'https://github.com/madeforyalo/redmine_pdf_preview_kaizen2b'
  author_url  'https://kaizen2b.com'
  requires_redmine version_or_higher: '6.0.0'
end
