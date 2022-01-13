module StripeMockHelper
  def self.included(base)
    def setup
      StripeMock.start
    end

    def teardown
      StripeMock.stop
    end

    protected

    def stripe_helper
      @stripe_helper ||= StripeMock.create_test_helper
    end

    def stripe_card_token
      stripe_helper.generate_card_token
    end
  end
end
