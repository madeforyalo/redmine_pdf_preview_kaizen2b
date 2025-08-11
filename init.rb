# frozen_string_literal: true
require_relative 'lib/redmine_pdf_preview_kaizen2b/engine'

Redmine::Plugin.register :redmine_pdf_preview_kaizen2b do
  name        'Redmine PDF Preview KaiZen2B'
  author      'KaiZen2B'
  description 'Inline PDF preview in Redmine using PDF.js + Office→PDF'
  version     '1.1.0'
  url         'https://github.com/madeforyalo/redmine_pdf_preview_kaizen2b'
  author_url  'https://kaizen2b.com'
  requires_redmine version_or_higher: '6.0.0'

  settings partial: 'settings/redmine_pdf_preview_kaizen2b',
           default: {
             'lo_bin'          => '/usr/lib/libreoffice/program/soffice',
             'lo_profile'      => '/tmp/libreoffice_profile',
             'home_override'   => '/var/www',
             'path_override'   => '/usr/bin:/bin',
             'tmpdir'          => '/tmp',
             'xdg_runtime'     => '/tmp',
             'convert_timeout' => 60,
             'cache_dir'       => 'tmp/pdf_previews'
           }
end
