class CreatePessoas < ActiveRecord::Migration
  def change
    create_table :pessoas do |t|
      t.string :nome
      t.string :cpf
      t.string :rg
      t.string :telefone
      t.string :endereco
      t.string :cep
      t.string :email
      t.string :valor
      t.string :vencimento
      t.string :cedente
      t.string :cnpj
      t.string :codigo
      t.references :empresa, index: true, foreign_key: true
      t.boolean :ativo

      t.timestamps null: false
    end
  end
end
