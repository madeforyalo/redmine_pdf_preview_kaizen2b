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

# frozen_string_literal: true
require 'open3'
require 'fileutils'

module RedminePdfPreviewKaizen2b
  module Services
    class OfficeToPdf
      def initialize(attachment, settings)
        @a = attachment
        @s = settings || {}
      end

      def call
        outdir = cache_dir_for(@a)
        FileUtils.mkdir_p(outdir)
        pdf = File.join(outdir, "#{base}.pdf")
        return pdf if File.exist?(pdf)

        FileUtils.mkdir_p(profile_dir)

        env = {
          'HOME'            => @s['home_override'] || '/var/www',
          'PATH'            => @s['path_override'] || '/usr/bin:/bin',
          'TMPDIR'          => @s['tmpdir'] || '/tmp',
          'XDG_RUNTIME_DIR' => @s['xdg_runtime'] || '/tmp',
          'LANG'            => 'en_US.UTF-8'
        }

        cmd = [
          lo_bin, '--headless',
          "-env:UserInstallation=file://#{profile_dir}",
          '--convert-to', 'pdf',
          @a.diskfile,
          '--outdir', outdir
        ]

        run_with_timeout(env, cmd, timeout)
        raise 'office2pdf: output not found' unless File.exist?(pdf)
        pdf
      end

      private

      def lo_bin       = (@s['lo_bin'].presence || '/usr/lib/libreoffice/program/soffice').to_s
      def profile_dir  = (@s['lo_profile'].presence || '/tmp/libreoffice_profile').to_s
      def base         = File.basename(@a.filename, File.extname(@a.filename))
      def cache_root   = Rails.root.join(@s['cache_dir'].presence || 'tmp/pdf_previews').to_s
      def cache_dir_for(a) = File.join(cache_root, a.id.to_s)
      def timeout      = (@s['convert_timeout'] || 60).to_i

      def run_with_timeout(env, cmd, timeout)
        stdout_str = stderr_str = nil; status = nil
        Open3.popen3(env, *cmd) do |stdin, out, err, thr|
          stdin.close
          if thr.join(timeout).nil?
            Process.kill('KILL', thr.pid) rescue nil
            stdout_str = out.read rescue ''
            stderr_str = err.read rescue ''
            Rails.logger.error("[office2pdf][timeout] #{cmd.join(' ')}\nstdout=#{stdout_str}\nstderr=#{stderr_str}")
            raise 'office2pdf: timeout'
          else
            stdout_str = out.read; stderr_str = err.read; status = thr.value
          end
        end
        unless status&.success?
          Rails.logger.error("[office2pdf][exit=#{status&.exitstatus}] #{cmd.join(' ')}\nstdout=#{stdout_str}\nstderr=#{stderr_str}")
          raise "office2pdf: exit #{status&.exitstatus}"
        end
      end
    end
  end
end
