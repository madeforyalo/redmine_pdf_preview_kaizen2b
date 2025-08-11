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

        # Nombre “esperado”
        expected_pdf = File.join(outdir, "#{base}.pdf")

        # Si ya existe, usarlo
        return expected_pdf if File.exist?(expected_pdf)

        # Perfil y ENV
        FileUtils.mkdir_p(profile_dir)
        env = {
          'HOME'            => @s['home_override'] || '/var/www',
          'PATH'            => @s['path_override'] || '/usr/bin:/bin',
          'TMPDIR'          => @s['tmpdir'] || '/tmp',
          'XDG_RUNTIME_DIR' => @s['xdg_runtime'] || '/tmp',
          'LANG'            => 'en_US.UTF-8'
        }

        # URI del perfil: siempre “file:///ruta”
        profile_uri = "file:///#{profile_dir.sub(%r{\A/+}, '')}"

        # Preferir wrapper /usr/bin/libreoffice; si no, soffice
        lo_bin = lo_bin_candidates.find { |p| File.executable?(p) } || lo_bin_candidates.first

        cmd = [
          lo_bin, '--headless',
          "-env:UserInstallation=#{profile_uri}",
          '--convert-to', 'pdf',
          @a.diskfile,
          '--outdir', outdir
        ]

        Rails.logger.info "[office2pdf] cmd=#{cmd.join(' ')} outdir=#{outdir}"

        run_with_timeout(env, cmd, timeout)

        # 1) ¿Está el esperado?
        return expected_pdf if File.exist?(expected_pdf)

        # 2) Si no, buscar cualquier PDF recién creado en el outdir
        latest_pdf = Dir[File.join(outdir, '*.pdf')].max_by { |f| File.mtime(f) rescue Time.at(0) }
        if latest_pdf
          Rails.logger.info "[office2pdf] fallback to generated file: #{latest_pdf}"
          return latest_pdf
        end

        # 3) Nada encontrado → error con detalles
        Rails.logger.error "[office2pdf] output not found in #{outdir}"
        raise 'office2pdf: output not found'
      end

      private

      def lo_bin_candidates
        [
          (@s['lo_bin'].presence || '/usr/bin/libreoffice'),
          '/usr/lib/libreoffice/program/soffice'
        ]
      end

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
        Rails.logger.info("[office2pdf] success exit=#{status.exitstatus}")
      end
    end
  end
end
