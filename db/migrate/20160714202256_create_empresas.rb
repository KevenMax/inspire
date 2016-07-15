class CreateEmpresas < ActiveRecord::Migration
  def change
    create_table :empresas do |t|
      t.string :nome
      t.string :endereco

      t.timestamps null: false
    end
  end
end
