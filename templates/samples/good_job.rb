# app/jobs/sidekiq_jobs/mine_crypto.rb

module SidekiqJobs
  class MineCrypto < BaseJob
    sidekiq_options queue: ...

    class << self
      def enqueue(user)
        raise "bad!" unless user.wallet.present?

        perform_async(user.network.id, user.id)
      end
    end

    def perform(network_id, user_id)
      user = User.find_by(
        id: user_id,
        network_id: network_id
      )

      return unless user&.wallet.present?

      # Blocks for a long time
      coins = CryptoMiner.mine_coins(3)

      # API request
      user.send_to_wallet!(coins)
    end
  end
end

