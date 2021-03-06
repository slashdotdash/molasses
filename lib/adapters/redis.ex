defmodule Molasses.StorageAdapter.Redis do
    alias Molasses.Util
    def get(client, key) do
        Exredis.Api.get client, "molasses_#{key}"
    end

    def set(client, key, value) do
        Exredis.Api.set client,  "molasses_#{key}", value
    end

    def remove(client, key) do
        Exredis.Api.del client,  "molasses_#{key}"
    end

    def activate(client, key) do
        set(client, key, "true|100|")
    end

    def activate(client, key, percentage) when is_integer(percentage) do
        set(client, key, "true|#{percentage}|")
    end

    def activate(client, key, users) when is_list(users) do
        activated_users = Enum.join(users,",")
        set(client, key, "true|100|#{activated_users}")
    end

    def activate(client, key, group) do
        set(client, key, "true|100|#{group}")
    end

    def deactivate(client, key) do
        set(client, key, "false|0|")
    end

    def get_feature(client, key) do
        case get(client, key) do
            :undefined -> {:error, "failure"}
            result -> 
                [active, percentage, users] = String.split(result, "|")
                %{
                    name: key,
                    active: Util.return_bool(active),
                    percentage: String.to_integer(percentage),
                    users: Util.convert_to_list(users),
                }
        end
    end


end