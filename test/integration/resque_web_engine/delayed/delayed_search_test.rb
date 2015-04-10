require_relative '../../../test_helper'

module ResqueWeb
  module Plugins
    module ResqueScheduler
      class DelayedSearchTest < ActionDispatch::IntegrationTest
        setup do
          t = Time.now + 60 # Random failures might be linked to this?
          Resque.enqueue_at(t, SomeIvarJob)
          Resque.enqueue(SomeQuickJob)
        end

        teardown do
          Resque.reset_delayed_queue
          Resque.queues.each { |q| Resque.remove_queue q }
        end

        test 'should find matching scheduled job' do
          post Engine.app.url_helpers.delayed_search_path, 'search' => 'ivar'
          assert response.status == 200
          assert response.body.include?('SomeIvarJob'), response.body
        end

        test 'should find matching queued job' do
          post Engine.app.url_helpers.delayed_search_path, 'search' => 'quick'
          assert response.status == 200
          assert response.body.include?('SomeQuickJob')
        end
      end
    end
  end
end