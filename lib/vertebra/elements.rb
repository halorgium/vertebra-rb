# Copyright 2008, Engine Yard, Inc.
#
# This file is part of Vertebra.
#
# Vertebra is free software: you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# Vertebra is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
# details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Vertebra.  If not, see <http://www.gnu.org/licenses/>.

module Vertebra
  class BaseElement < Jabber::XMPPElement
    def initialize(client, token)
      super()
      @client = client
      add_attribute('token', token)
    end
    attr_reader :client

    def token
      attributes['token']
    end
  end

  class Authorization < Jabber::XMPPElement
    name_xmlns 'authorization', 'http://xmlschema.engineyard.com/agent/api'
    force_xmlns true

    def initialize(from = nil, to = nil)
      super()
      add_attribute('from', from)
      add_attribute('to', to)
    end

  end

  class Ack < BaseElement
    name_xmlns 'ack', 'http://xmlschema.engineyard.com/agent/api'
    force_xmlns true
  end

  class Nack < BaseElement
    name_xmlns 'nack', 'http://xmlschema.engineyard.com/agent/api'
    force_xmlns true
  end

  class Final < BaseElement
    name_xmlns 'final', 'http://xmlschema.engineyard.com/agent/api'
    force_xmlns true
  end

  class Data < BaseElement
    name_xmlns 'data', 'http://xmlschema.engineyard.com/agent/api'
  end

  class Error < BaseElement
    name_xmlns 'error', 'http://xmlschema.engineyard.com/agent/api'
  end

  module Stanzas
  class Init < BaseElement
    name_xmlns 'op', 'http://xmlschema.engineyard.com/agent/api'
    force_xmlns true

    def initialize(client, type, to, args)
      super(client, Vertebra.gen_token)
      @type = Vertebra::Resource.new(type.to_s)
      @to = to
      @args = args

      pp [@type, @to, @args]

      add_attribute('type', @type.to_s)
    end

    def type
      attributes['type']
    end

    def to_iq
      iq = LM::Message.new(@to, LM::MessageType::IQ, type)

      iq.node.set_attribute('xml:lang','en')
      iq.node.add_child(self)
      op_lm = iq.node.get_child(name)

      Vertebra::Marshal.encode(@args).children.each do |el|
        op_lm.add_child el
      end
      logger.debug "CREATED IQ #{iq.node.to_s} with class #{iq.class}"
      iq
    end
  end
  end

  class Res < Jabber::XMPPElement
    name_xmlns 'res', 'http://xmlschema.engineyard.com/agent/api'

    def initialize(res = nil, name = nil)
      super()
      add_attribute('name', name)
      self.text = res
    end
  end

end
