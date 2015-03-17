# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'busser/thor'
require 'busser/plugin'

module Busser

  module Command

    # Setup command.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    #
    class Setup < Busser::Thor::BaseGroup

      def perform
        banner "Setting up Busser"
        create_busser_root
        generate_busser_binstub
      end

      private

      def create_busser_root
        info "Creating BUSSER_ROOT in #{root_path}"
        empty_directory(root_path, :verbose => false)
      end

      def generate_busser_binstub
        binstub = root_path + "bin/busser"

        info "Creating busser binstub"
        File.unlink(binstub) if File.exists?(binstub)
        create_file(binstub, :verbose => false) do
          <<-BUSSER_BINSTUB.gsub(/^ {12}/, '')
            #!/usr/bin/env sh
            #
            # This file was generated by Busser.
            #
            # The application 'busser' is installed as part of a gem, and
            # this file is here to facilitate running it.
            #
            if test -n "$DEBUG"; then set -x; fi

            # Set Busser Root path
            BUSSER_ROOT="#{root_path}"

            export BUSSER_ROOT

            # Export gem paths so that we use the isolated gems.
            GEM_HOME="#{gem_home}"; export GEM_HOME
            GEM_PATH="#{gem_path}"; export GEM_PATH
            GEM_CACHE="#{gem_home}/cache"; export GEM_CACHE

            # Unset RUBYOPT, we don't want this bleeding into our runtime.
            unset RUBYOPT GEMRC

            # Call the actual Busser bin with our arguments
            exec "#{ruby_bin}" "#{gem_bindir}/busser" "$@"
          BUSSER_BINSTUB
        end
        chmod(binstub, 0755, :verbose => false)
      end

      def ruby_bin
        if bindir = RbConfig::CONFIG["bindir"]
          File.join(bindir, "ruby")
        else
          "ruby"
        end
      end

      def gem_home
        Gem.paths.home
      end

      def gem_path
        Gem.paths.path.join(":")
      end

      def gem_bindir
        Gem.bindir
      end
    end
  end
end
