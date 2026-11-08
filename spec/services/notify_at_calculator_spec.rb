require 'rails_helper'

RSpec.describe NotifyAtCalculator do
  describe '.first_notify_at' do
    subject do
      described_class.first_notify_at(
        base_time: base_time,
        interval_unit: interval_unit,
        notify_day_of_week: notify_day_of_week,
        notify_day_of_month: notify_day_of_month,
        notify_hour: notify_hour
      )
    end

    # 曜日・日は両方とも必ず値が入っている前提（使う方を interval_unit で決める）
    let(:notify_day_of_week) { 1 }  # 月曜
    let(:notify_day_of_month) { 1 } # 1日
    let(:notify_hour) { 9 }

    context '週単位の場合' do
      let(:interval_unit) { 'week' }

      context '月曜9時設定' do
        context '木曜の午後に作成した場合' do
          let(:base_time) { Time.zone.local(2026, 10, 22, 15, 46) }

          it '翌週の月曜9時になること' do
            expect(subject).to eq Time.zone.local(2026, 10, 26, 9, 0)
          end
        end

        context '月曜8時に作成した場合' do
          let(:base_time) { Time.zone.local(2026, 10, 19, 8, 0) }

          it '同じ日の9時になること' do
            expect(subject).to eq Time.zone.local(2026, 10, 19, 9, 0)
          end
        end

        context '月曜9:00ちょうどに作成した場合' do
          let(:base_time) { Time.zone.local(2026, 10, 19, 9, 0, 0) }

          it '翌週の月曜9時になること' do
            expect(subject).to eq Time.zone.local(2026, 10, 26, 9, 0)
          end
        end

        context '年末（12/31 木曜）に作成した場合' do
          let(:base_time) { Time.zone.local(2026, 12, 31, 12, 0) }

          it '翌年最初の月曜9時になること' do
            expect(subject).to eq Time.zone.local(2027, 1, 4, 9, 0)
          end
        end
      end

      context '水曜9時設定' do
        let(:notify_day_of_week) { 3 }

        context '同じ週の月曜10時に作成した場合' do
          let(:base_time) { Time.zone.local(2026, 10, 19, 10, 0) }

          it '同じ週の水曜9時になること' do
            expect(subject).to eq Time.zone.local(2026, 10, 21, 9, 0)
          end
        end
      end
    end

    context '月単位の場合' do
      let(:interval_unit) { 'month' }

      context '1日9時設定' do
        context '1日の8時に作成した場合' do
          let(:base_time) { Time.zone.local(2026, 10, 1, 8, 0) }

          it '同じ日の9時になること' do
            expect(subject).to eq Time.zone.local(2026, 10, 1, 9, 0)
          end
        end

        context '1日の9:00ちょうどに作成した場合' do
          let(:base_time) { Time.zone.local(2026, 10, 1, 9, 0, 0) }

          it '翌月1日の9時になること' do
            expect(subject).to eq Time.zone.local(2026, 11, 1, 9, 0)
          end
        end

        context '10/9に作成した場合（3ヶ月に1回でも回数は使わない）' do
          let(:base_time) { Time.zone.local(2026, 10, 9, 12, 0) }

          it '直近の11/1 9時になること' do
            expect(subject).to eq Time.zone.local(2026, 11, 1, 9, 0)
          end
        end

        context '12/15に作成した場合' do
          let(:base_time) { Time.zone.local(2026, 12, 15, 12, 0) }

          it '翌年1/1の9時になること' do
            expect(subject).to eq Time.zone.local(2027, 1, 1, 9, 0)
          end
        end
      end

      context '15日9時設定' do
        let(:notify_day_of_month) { 15 }

        context '同じ月の10日に作成した場合' do
          let(:base_time) { Time.zone.local(2026, 10, 10, 12, 0) }

          it '同じ月の15日9時になること' do
            expect(subject).to eq Time.zone.local(2026, 10, 15, 9, 0)
          end
        end
      end
    end
  end

  describe '.following_notify_at' do
    subject do
      described_class.following_notify_at(
        previous_notify_at: previous_notify_at,
        interval_unit: interval_unit,
        interval_count: interval_count
      )
    end

    context '週単位の場合' do
      let(:interval_unit) { 'week' }

      context '週1回' do
        let(:interval_count) { 1 }

        context '前回が10/19（月）9時の場合' do
          let(:previous_notify_at) { Time.zone.local(2026, 10, 19, 9, 0) }

          it '1週間後の10/26（月）9時になること' do
            expect(subject).to eq Time.zone.local(2026, 10, 26, 9, 0)
          end
        end

        context '前回が12/28（月）9時の場合' do
          let(:previous_notify_at) { Time.zone.local(2026, 12, 28, 9, 0) }

          it '年をまたいで翌年1/4（月）9時になること' do
            expect(subject).to eq Time.zone.local(2027, 1, 4, 9, 0)
          end
        end
      end
    end

    context '月単位の場合' do
      let(:interval_unit) { 'month' }
      let(:previous_notify_at) { Time.zone.local(2026, 11, 1, 9, 0) }

      context '月1回' do
        let(:interval_count) { 1 }

        it '1ヶ月後の12/1 9時になること' do
          expect(subject).to eq Time.zone.local(2026, 12, 1, 9, 0)
        end

        context '前回が28日の場合' do
          let(:previous_notify_at) { Time.zone.local(2027, 1, 28, 9, 0) }

          it '月末でもずれず2/28 9時になること' do
            expect(subject).to eq Time.zone.local(2027, 2, 28, 9, 0)
          end
        end
      end

      context '3ヶ月に1回' do
        let(:interval_count) { 3 }

        it '年をまたいで翌年2/1 9時になること' do
          expect(subject).to eq Time.zone.local(2027, 2, 1, 9, 0)
        end
      end

      context '半年に1回' do
        let(:interval_count) { 6 }

        it '翌年5/1 9時になること' do
          expect(subject).to eq Time.zone.local(2027, 5, 1, 9, 0)
        end
      end

      context '年に1回' do
        let(:interval_count) { 12 }

        it '翌年11/1 9時になること' do
          expect(subject).to eq Time.zone.local(2027, 11, 1, 9, 0)
        end
      end
    end
  end
end
