module Import
  module OTRS
    module ImportStats
      # rubocop:disable Style/ModuleFunction
      extend self

      def current_state
        {
          Base: {
            done:  base_done,
            total: base_total,
          },
          User: {
            done:  user_done,
            total: user_total,
          },
          Ticket: {
            done:  ticket_done,
            total: ticket_total,
          },
        }
      end

      private

      def statistic

        # check cache
        cache = Cache.get('import_otrs_stats')
        return cache if cache

        # retrive statistic
        statistic = Import::OTRS::Requester.list
        return statistic if !statistic

        Cache.write('import_otrs_stats', statistic)
        statistic
      end

      def base_done
        ::Group.count + ::Ticket::State.count + ::Ticket::Priority.count
      end

      def base_total
        sum_stat(%w(Queue State Priority))
      end

      def user_done
        ::User.count
      end

      def user_total
        sum_stat(%w(User CustomerUser))
      end

      def ticket_done
        ::Ticket.count
      end

      def ticket_total
        sum_stat(%w(Ticket))
      end

      def sum_stat(objects)
        data = statistic
        sum  = 0
        objects.each { |object|
          sum += data[object]
        }
        sum
      end
    end
  end
end
