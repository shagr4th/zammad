require 'rails_helper'
require 'import/import_factory_examples'

RSpec.describe Import::OTRS::Article::AttachmentFactory do
  it_behaves_like 'Import factory'

  def load_attachment_json(file)
    json_fixture("import/otrs/article/attachment/#{file}")
  end

  let(:local_article) { instance_double(Ticket::Article, ticket_id: 1337, id: 42) }
  let(:attachments) {
    [
      load_attachment_json('default'),
      load_attachment_json('default'),
      load_attachment_json('default')
    ]
  }
  let(:start_import) {
    described_class.import(
      attachments:   attachments,
      local_article: local_article
    )
  }

  def import_expectations
    expect(Store).to receive(:add).exactly(3).times.with(hash_including(
                                                           object: 'Ticket::Article',
                                                           o_id:   local_article.id,
    ))
  end

  def article_attachment_expectations(article_attachments)
    expect(local_article).to receive(:attachments).and_return(article_attachments)
  end

  it 'imports' do
    article_attachment_expectations([])
    import_expectations
    start_import
  end

  it 'deletes old and reimports' do
    dummy_attachment = double()
    expect(dummy_attachment).to receive(:delete)
    article_attachment_expectations([dummy_attachment])
    import_expectations
    start_import
  end

  it 'skips import for same count' do
    article_attachment_expectations([1, 2, 3])
    expect(Store).not_to receive(:add)
    start_import
  end
end
