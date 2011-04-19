module EventCalendar
  module CalendarHelper
    private

    # calculate the height of each row
    # by default, it will be the height option minus the day names height,
    # divided by the total number of calendar rows
    # this gets tricky, however, if there are too many event rows to fit into the row's height
    # then we need to add additional height
    def cal_row_heights(options)
      # number of rows is the number of days in the event strips divided by 7
      num_cal_rows = (options[:event_strips].first.size / 7).to_i
      # the row will be at least this big
      min_height = ((options[:height] - options[:day_names_height]) / num_cal_rows).to_i
      row_heights = []
      num_event_rows = 0
      # for every day in the event strip...
      1.upto(options[:event_strips].first.size+1) do |index|
        num_events = 0
        # get the largest event strip that has an event on this day
        options[:event_strips].each_with_index do |strip, strip_num|
          num_events = strip_num + 1 unless strip[index-1].blank?
        end
        # get the most event rows for this week
        num_event_rows = [num_event_rows, num_events].max
        # if we reached the end of the week, calculate this row's height
        if index % 7 == 0
          total_event_height = options[:event_height] + options[:event_margin]
          calc_row_height = (num_event_rows * total_event_height) + options[:day_nums_height] + options[:event_margin]
          row_height = [min_height, calc_row_height].max
          row_heights << row_height
          num_event_rows = 0
        end
      end
      row_heights
    end
  end
end
