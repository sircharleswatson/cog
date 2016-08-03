# TODO: DOCUMENT THE USAGE OF ALL THESE MESSAGE TYPES}
# TODO: Add documentation macro to the "field" function call??
defmodule Cog.Messages.Room do
  use Conduit

  field :id, :string, required: true
  # Somehow, we don't always have a name??
  field :name, :string, required: false
end

defmodule Cog.Messages.SendMessage do
  use Conduit

  field :id, :string, required: true
  field :response, :string, required: true
  field :room, :map, required: true #Cog.Messages.Room, required: true
end

# Was Cog.Command.Response
defmodule Cog.Messages.CommandResponse do
  use Conduit

  field :template, :string, required: false # TODO: actually seeing some with NULL
  field :status_message, :string, required: false # TODO: actually seeing some with NULL
  field :status, :string, enum: ["ok", "error", "abort"], required: true

  # TODO: map or array... can this be expressed?
  # Not all responses currently have bodies, either... see GenCommand#send_error_reply
  field :body, :map_or_array_of_maps # UGH
end

defmodule Cog.Messages.User do
  use Conduit

  # This is effectively a subset of Cog.Models.User :/
  field :email_address, :string, required: true
  field :first_name, :string, required: true
  field :last_name, :string, required: true
  field :username, :string, required: true # cog username
  field :id, :string, required: true
end

# Was Cog.Command.Request
defmodule Cog.Messages.Command do
  use Conduit

  # Could be an array of strings, integers, etc. or any combination of those
  field :args, :array, required: true
  field :options, :map, required: true
  field :cog_env, :map, required: true
  field :command, :string, required: true
  field :invocation_id, :string, required: true

  # TODO: apparently sometimes this is nil??? Under what circumstances?
  # TODO: is this a string if not "first" or "last"?
  field :invocation_step, :string, required: false
  field :reply_to, :string, required: true

  # TODO: rename this "sender"?
  field :requestor, Cog.Messages.Sender, required: true

  field :room, :map, required: true #Cog.Messages.Room, required: true

  field :service_token, :string, required: true
  field :services_root, :string, required: true

  field :user, Cog.Messages.User, required: true
end

defmodule Cog.Messages.Sender do
  use Conduit
  # all fields *should be* required; id and handle are used most
  # frequently, but the rest are used when auto-registering users with
  # Cog (and that only currently works with Slack, by design)
  #
  # HOWEVER
  #
  # This doesn't really apply for trigger users...
  field :id, :string, required: false # chat client internal ID
  field :handle, :string, required: false # chat handle
  field :first_name, :string, required: false
  field :last_name, :string, required: false
  field :email, :string, required: false
end

defmodule Cog.Messages.AdapterRequest do
  use Conduit

  # Command coming in from Chat
  field :text, :string, required: true

  field :sender, Cog.Messages.Sender, required: true

  field :room, :map, required: true #Cog.Messages.Room, required: true
  field :reply, :string, required: true

  # Adapter module... TODO: resolve it to an actual Module reference?
  field :module, :string, required: true

  field :initial_context, :map, required: true

  field :id, :string, required: true

  # Short name of adapter, e.g. "slack"
  field :adapter, :string, required: true
end

defmodule Cog.Messages.Relay.ListBundles do
  use Conduit
  field :relay_id, :string, required: true
  field :reply_to, :string, required: true
end

defmodule Cog.Messages.Relay.GetDynamicConfigs do
  use Conduit

  field :relay_id, :string, required: true
  field :config_hash, :string, required: true
  field :reply_to, :string, required: true
end

# TODO: Make Cog listen on different topics for these messages
defmodule Cog.Messages.RelayInfo do
  use Conduit
  field :get_dynamic_configs, Cog.Messages.Relay.GetDynamicConfigs, required: false
  field :list_bundles, Cog.Messages.Relay.ListBundles, required: false
end

defmodule Cog.Messages.Relay.Bundle do
  use Conduit

  field :name, :string, required: true
  field :version, :string, required: true
end

defmodule Cog.Messages.Relay.Announcement do
  use Conduit

  field :announcement_id, :string, required: true
  field :relay, :string, required: true # relay identifier
  field :online, :bool, required: true

  # It's nil when we get the offline / last-will message
  field :bundles, [array: Cog.Messages.Relay.Bundle], required: false
  field :snapshot, :bool, required: true
  field :reply_to, :string, required: true
end

# TODO: Unwrap this
defmodule Cog.Messages.Relay.Announce do
  use Conduit
  field :announce, Cog.Messages.Relay.Announcement, required: true
end

defmodule Cog.Messages.Relay.Receipt do
  use Conduit

  field :announcement_id, :string, required: true
  field :status, :string, required: true, enum: ["success", "failed"]
  # TODO: this  should be simplified: see relays#receipt
  field :bundles, :array, required: true
end

# List of bundle configs to send to a Relay
defmodule Cog.Messages.Relay.BundleResponse do
  use Conduit
  field :bundles, [array: :map], required: true
end

defmodule Cog.Messages.Relay.DynamicConfigResponse do
  use Conduit

  field :changed, :bool, required: true
  field :configs, :map, required: false      # TODO: required if changed = true
  field :signature, :string, required: false # TODO: required if changed = true

  # TODO: Wonder if we should have a separate message type for un-changed responses?
end
