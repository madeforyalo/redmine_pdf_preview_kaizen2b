# frozen_string_literal: true

require 'open3'
require 'fileutils'

module RedminePdfPreviewKaizen2b
  module Services
    class OfficeToPdf
      def initialize(attachment, settings)
        @attachment = attachment
        @settings = settings || {}
      end

      def call
        cachedir = cache_dir
        pdf_path = File.join(cachedir, "#{basename}.pdf")
        return pdf_path if File.exist?(pdf_path)

        FileUtils.mkdir_p(@settings['lo_profile'] || '/tmp/libreoffice_profile')
        FileUtils.mkdir_p(cachedir)

        env = {
          'HOME' => @settings['home_override'] || '/var/www',
          'PATH' => @settings['path_override'] || '/usr/bin:/bin',
          'TMPDIR' => @settings['tmpdir'] || '/tmp',
          'XDG_RUNTIME_DIR' => @settings['xdg_runtime'] || '/tmp',
          'LANG' => 'en_US.UTF-8'
        }

        cmd = [
          @settings['lo_bin'] || '/usr/lib/libreoffice/program/soffice',
          '--headless',
          "-env:UserInstallation=file://#{@settings['lo_profile'] || '/tmp/libreoffice_profile'}",
          '--convert-to', 'pdf', @attachment.diskfile.to_s,
          '--outdir', cachedir
        ]

        stdout_str = ''
        stderr_str = ''
        status = nil

        Open3.popen3(env, *cmd) do |stdin, stdout, stderr, wait_thr|
          stdin.close
          stdout_str = stdout.read
          stderr_str = stderr.read
          timeout = (@settings['convert_timeout'] || 60).to_i
          status = wait_thr.join(timeout)&.value
          unless status
            Process.kill('TERM', wait_thr.pid) rescue nil
            Rails.logger.error("[office_preview] timeout #{timeout}s cmd=#{cmd.join(' ')} stdout=#{stdout_str} stderr=#{stderr_str}")
            raise 'LibreOffice conversion timeout'
          end
          unless status.success?
            Rails.logger.error("[office_preview] cmd=#{cmd.join(' ')} exit=#{status.exitstatus} stdout=#{stdout_str} stderr=#{stderr_str}")
            raise 'LibreOffice conversion failed'
          end
        end

        unless File.exist?(pdf_path)
          Rails.logger.error("[office_preview] PDF not generated for attachment #{@attachment.id}")
          raise 'PDF not generated'
        end

        pdf_path
      end

      private

      def cache_dir
        File.join(Rails.root, (@settings['cache_dir'] || 'tmp/pdf_previews'), @attachment.id.to_s)
      end

      def basename
        File.basename(@attachment.diskfile, File.extname(@attachment.diskfile))
      end
    end
  end
end
