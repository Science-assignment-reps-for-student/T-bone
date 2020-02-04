class MessagesChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'chat_message_channel'
    ActionCable.server.broadcast('chat_message_channel', content: 'hello world!')
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
