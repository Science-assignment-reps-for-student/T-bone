class MessagesChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'some_channel'
    ActionCable.server.broadcast('some_channel', content: 'hello world!')
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
