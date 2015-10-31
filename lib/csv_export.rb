module CsvExport
  require 'csv'
  require 'zip'

  # generates a csv from the given model data
  def generate_csv(data)
    objects = data.first
    columns = data.size == 1 ? objects.first.attributes.keys : data[1]

    # we never need to export ids
    columns.delete('id')

    CSV.generate(headers: true) do |csv|
      csv << columns

      objects.each do |o|
        csv << columns.map do |attr|
          s = o.send(attr)
          if s.is_a? ActiveRecord::Base
            s.name
          else s
          end
        end
      end
    end
  end

  # generates a zip file containing multiple CSVs
  def generate_zip(data)
    # create the CSVs
    csvs = data.map { |model| generate_csv(model) }

    Zip::OutputStream.write_buffer do |stream|
      csvs.each_with_index do |csv, i|
        model_name = data[i].first.first.class.name
        stream.put_next_entry "#{model_name}_#{Time.zone.today}.csv"
        stream.write csv
      end
    end.string
  end

  # downloads a csv of the given model data
  # expects data to be an array with the following format:
  # [objects, columns]
  # where columns is optional; defaults to all columns except id
  def download_csv(data, filename)
    send_data(generate_csv(data), filename: "#{filename}.csv")
  end

  # downloads a zip file containing multiple CSVs
  # expects data to be an array of arrays with the following format:
  # [[objects, columns], ...]
  # where columns is optional; defaults to all columns except id
  def download_zip(data, filename)
    send_data(generate_zip(data), type: 'application/zip',
                                  filename: "#{filename}.zip")
  end

  def download_equipment_data
    categories = [Category.all, %w(name max_per_user max_checkout_length
                                   max_renewal_times max_renewal_length
                                   renewal_days_before_due sort_order)]
    models = [EquipmentModel.all, %w(category name description late_fee
                                     replacement_fee max_per_user
                                     max_renewal_length)]
    items = [EquipmentItem.all, %w(equipment_model name serial)]
    download_zip([categories, models, items],
                 "EquipmentData_#{Time.zone.today}")
  end
end
