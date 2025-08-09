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
