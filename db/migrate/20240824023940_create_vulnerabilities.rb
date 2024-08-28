# class CreateVulnerabilities < ActiveRecord::Migration[7.2]
#   def change
#     create_table :vulnerabilities do |t|
#       t.string :os
#       t.text :description
#       t.string :severity
#       t.string :ip_address

#       t.references :admin_user

#       t.timestamps
#     end
#   end
# end


class CreateVulnerabilities < ActiveRecord::Migration[7.2]
  def change
    create_table :vulnerabilities do |t|
      t.string :os
      t.string :object_hash
      t.string :name
      t.string :cve_id
      t.string :target
      t.string :service
      t.string :evidence
      t.string :severity
      t.text :solution
      t.string :scan_name
      t.string :cvss_score
      t.string :ip_address
      t.string :pci_status
      t.string :target_tag
      t.text :description
      t.string :host_status
      t.string :project_name
      t.string :discovered_date
      t.string :last_scanned_date
      t.string :service_description
      t.string :approved_false_positive_evidence
      t.integer :status, default: 0

      t.references :vulnerability_scan
      t.references :admin_user

      t.timestamps
    end
  end
end
