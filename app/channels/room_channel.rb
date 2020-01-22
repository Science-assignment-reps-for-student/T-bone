class RoomChannel < ApplicationController
  include ActionCable::Channel

  before_subscribe :jwt_required

  def subscribed
    # stream_from "some_channel"
    stream_for room
    RoomChannel.all_messages
  end

  private

  def room
    Chat.find_by_user_id(@@jwt_base.get_jwt_payload(request.authorization))
  end

  def self.all_messages
    payload = @@jwt_base.get_jwt_payload(request.authorization)
    history = []

    Chat.where(user_id: payload['user_id']).order(created_at: :asc)
        .offset(10 * params.permit(page: Integer)).each do |chat|
      history.append(chat.chat_message)
    end

    ActionCable.server.broadcast(room, history: history)
  end

  def speak
    payload = @@jwt_base.get_jwt_payload(request.authorization)
    content = params.permit(content: String)

    User.find_by_id(payload['user_id'])
        .chats.create!(chat_message: content, created_at: Time.now.to_i)

    ActionCable.server.broadcast(room, content: content)
  end
end
