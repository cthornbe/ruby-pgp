require 'spec_helper'

describe GPG::TempPathHelper do
  it 'creates a temporary file path' do
    path = GPG::TempPathHelper.create

    expect(path.start_with?(Dir.tmpdir)).to eq(true)
    expect(File.exist?(path)).to eq(false)
  end

  it 'creates unique paths every time' do
    paths = (1..100).map { GPG::TempPathHelper.create }

    expect(paths.uniq).to eq(paths)
    expect(paths.length).to eq(100)
  end

  it 'can receive an execution block' do
    path2 = nil
    path1 = GPG::TempPathHelper.create do |p|
      path2 = p
    end

    expect(path2).to eq(path1)
  end

  it 'deletes the temporary file if it exists' do
    path = GPG::TempPathHelper.create do |p|
      File.write(p, 'test')
      expect(File.exist?(p)).to eq(true)
    end

    expect(File.exist?(path)).to eq(false)
  end

  it 'deletes the temporary file even when there is an exception in the block' do
    exception_raised = false
    path = nil
    begin
      GPG::TempPathHelper.create do |p|
        path = p
        File.write(p, 'test')
        expect(File.exist?(p)).to eq(true)
        value = 45 / 0
      end
    rescue
      exception_raised = true
    end

    expect(exception_raised).to eq(true)
    expect(File.exist?(path)).to eq(false)
  end
end