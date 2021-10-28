# Copyright (C) 2012-2021 Zammad Foundation, http://zammad-foundation.org/

require 'rails_helper'

RSpec.describe Gql::Queries::Session, type: :request do

  context 'when checking the sessioin' do
    let(:agent) { create(:agent) }
    let(:query) { File.read(Rails.root.join('app/frontend/apps/mobile/graphql/queries/session.graphql')) }
    let(:graphql_response) do
      post '/graphql', params: { query: query }, as: :json
      json_response
    end

    context 'with valid session', authenticated_as: :agent do
      it 'has data' do
        expect(graphql_response['data']['session']['sessionId']).to be_present
      end
    end

    context 'without a valid session' do
      it 'fails' do
        expect(graphql_response['errors'][0]['message']).to eq('An object of type Session was hidden due to permissions')
      end
    end
  end
end