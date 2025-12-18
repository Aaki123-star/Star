#!/usr/bin/env node

const http = require('http');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');
const url = require('url');

const PORT = 8080;

// WEB URL CONFIGURATION
// Set these to match your web server setup
const WEB_ROOT = 'C:\\xampp\\htdocs';  // Windows: C:\xampp\htdocs  Linux: /var/www/html
const BASE_URL = 'http://localhost';    // Your domain: http://localhost or http://yourdomain.com

// HTML + React Frontend (embedded)
const HTML_CONTENT = `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>React File Manager - Standalone</title>
    <script crossorigin src="https://unpkg.com/react@18/umd/react.production.min.js"></script>
    <script crossorigin src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js"></script>
    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { background: #1a1b1e; color: #e4e6eb; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif; font-size: 13px; line-height: 1.5; min-height: 100vh; padding: 20px; }
        .container { max-width: 1400px; margin: 0 auto; }
        h1 { font-size: 16px; font-weight: 500; color: #e4e6eb; margin-bottom: 4px; }
        .subtitle { color: #9ca3af; font-size: 13px; margin-bottom: 20px; }
        .alert { padding: 10px 12px; border-radius: 4px; margin-bottom: 12px; font-size: 13px; border: 1px solid; animation: slideIn 0.3s ease; }
        @keyframes slideIn { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }
        .alert-success { background: rgba(34, 197, 94, 0.1); border-color: rgba(34, 197, 94, 0.3); color: #22c55e; }
        .alert-danger { background: rgba(239, 68, 68, 0.1); border-color: rgba(239, 68, 68, 0.3); color: #ef4444; }
        .alert-info { background: rgba(59, 130, 246, 0.1); border-color: rgba(59, 130, 246, 0.3); color: #3b82f6; }
        .section { background: rgba(255, 255, 255, 0.03); border: 1px solid rgba(255, 255, 255, 0.08); border-radius: 4px; padding: 14px; margin-bottom: 12px; }
        .section-title { font-size: 13px; font-weight: 500; color: #e4e6eb; margin-bottom: 10px; }
        .input-group { display: flex; gap: 6px; margin-bottom: 6px; }
        .input-group:last-child { margin-bottom: 0; }
        input[type="text"], input[type="file"], textarea { background: rgba(0, 0, 0, 0.2); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 4px; padding: 6px 10px; color: #e4e6eb; font-family: inherit; font-size: 13px; transition: all 0.15s ease; outline: none; flex: 1; }
        input[type="text"]:focus, textarea:focus { border-color: rgba(34, 197, 94, 0.3); background: rgba(0, 0, 0, 0.3); }
        input[type="file"] { cursor: pointer; }
        textarea { font-family: 'Courier New', monospace; resize: vertical; min-height: 400px; line-height: 1.5; font-size: 12px; width: 100%; }
        .btn { background: rgba(255, 255, 255, 0.06); color: #e4e6eb; border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 4px; padding: 6px 12px; font-size: 13px; cursor: pointer; transition: all 0.15s ease; white-space: nowrap; }
        .btn:hover { background: rgba(255, 255, 255, 0.1); }
        .btn:disabled { opacity: 0.5; cursor: not-allowed; }
        .btn-primary { background: rgba(34, 197, 94, 0.15); color: #22c55e; border-color: rgba(34, 197, 94, 0.3); }
        .btn-primary:hover { background: rgba(34, 197, 94, 0.25); }
        .btn-danger { background: rgba(239, 68, 68, 0.15); color: #ef4444; border-color: rgba(239, 68, 68, 0.3); }
        .btn-danger:hover { background: rgba(239, 68, 68, 0.25); }
        .btn-sm { padding: 4px 10px; font-size: 12px; }
        .url-link { color: #3b82f6; text-decoration: none; font-size: 11px; display: inline-flex; align-items: center; gap: 4px; cursor: pointer; }
        .url-link:hover { color: #60a5fa; text-decoration: underline; }
        .url-display { font-family: 'Courier New', monospace; font-size: 11px; color: #9ca3af; max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .btn-url { background: rgba(59, 130, 246, 0.15); color: #3b82f6; border-color: rgba(59, 130, 246, 0.3); }
        .btn-url:hover { background: rgba(59, 130, 246, 0.25); }
        .grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
        table { width: 100%; border-collapse: collapse; background: transparent; border: 1px solid rgba(255, 255, 255, 0.08); border-radius: 4px; overflow: hidden; }
        thead { background: rgba(255, 255, 255, 0.03); }
        th { padding: 8px 12px; font-weight: 500; text-align: left; color: #9ca3af; font-size: 12px; border-bottom: 1px solid rgba(255, 255, 255, 0.08); }
        td { padding: 8px 12px; border-top: 1px solid rgba(255, 255, 255, 0.05); font-size: 13px; }
        tbody tr { transition: background 0.15s ease; }
        tbody tr:hover { background: rgba(255, 255, 255, 0.03); }
        .file-name { color: #e4e6eb; cursor: pointer; display: inline-flex; align-items: center; gap: 6px; }
        .file-name:hover { color: #22c55e; }
        .file-icon { opacity: 0.6; }
        .action-buttons { display: flex; gap: 4px; flex-wrap: wrap; justify-content: flex-end; }
        .bulk-actions { display: flex; gap: 8px; align-items: center; margin-bottom: 12px; padding: 12px; background: rgba(255, 255, 255, 0.03); border: 1px solid rgba(255, 255, 255, 0.08); border-radius: 4px; }
        .bulk-actions-text { color: #9ca3af; font-size: 13px; flex: 1; }
        input[type="checkbox"] { appearance: none; width: 16px; height: 16px; border: 1px solid rgba(255, 255, 255, 0.2); border-radius: 3px; background: rgba(0, 0, 0, 0.3); cursor: pointer; position: relative; transition: all 0.15s ease; }
        input[type="checkbox"]:checked { background: rgba(34, 197, 94, 0.2); border-color: #22c55e; }
        input[type="checkbox"]:checked::after { content: '✓'; position: absolute; top: -1px; left: 2px; color: #22c55e; font-size: 12px; font-weight: bold; }
        .modal { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0, 0, 0, 0.7); display: flex; align-items: center; justify-content: center; z-index: 1000; }
        .modal-content { background: #2a2d35; padding: 20px; border-radius: 8px; min-width: 400px; max-width: 90vw; max-height: 90vh; border: 1px solid rgba(255, 255, 255, 0.1); overflow-y: auto; }
        .modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }
        .modal-title { font-size: 16px; font-weight: 500; color: #e4e6eb; }
        .close { color: #9ca3af; font-size: 24px; cursor: pointer; }
        .close:hover { color: #e4e6eb; }
        .terminal-output { background: rgba(0, 0, 0, 0.3); border: 1px solid rgba(34, 197, 94, 0.3); border-radius: 4px; padding: 12px; font-family: 'Courier New', monospace; font-size: 12px; color: #22c55e; white-space: pre-wrap; margin-top: 12px; max-height: 300px; overflow-y: auto; }
        .chmod-group { margin-bottom: 10px; }
        .chmod-group label { display: block; margin-bottom: 5px; color: #9ca3af; font-size: 12px; }
        .loading { text-align: center; padding: 40px; color: #9ca3af; }
        @media (max-width: 768px) { .grid-2 { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
    <div id="root"></div>
    <script type="text/babel">
        const { useState, useEffect } = React;
        const API_URL = '/api';

        function FileManager() {
            const [currentPath, setCurrentPath] = useState('');
            const [files, setFiles] = useState([]);
            const [notification, setNotification] = useState('');
            const [errorMsg, setErrorMsg] = useState('');
            const [loading, setLoading] = useState(false);
            const [selectedItems, setSelectedItems] = useState([]);
            const [editingFile, setEditingFile] = useState(null);
            const [viewingFile, setViewingFile] = useState(null);
            const [renamingItem, setRenamingItem] = useState(null);
            const [chmodItem, setChmodItem] = useState(null);
            const [newFileName, setNewFileName] = useState('');
            const [newFolderName, setNewFolderName] = useState('');
            const [editContent, setEditContent] = useState('');
            const [renameValue, setRenameValue] = useState('');
            const [chmodValue, setChmodValue] = useState('');
            const [commandInput, setCommandInput] = useState('');
            const [commandOutput, setCommandOutput] = useState('');
            const [pathInput, setPathInput] = useState('');

            useEffect(() => { loadDirectory(currentPath); }, []);
            useEffect(() => { setPathInput(currentPath); }, [currentPath]);

            const showNotification = (msg, isError = false) => {
                if (isError) { setErrorMsg(msg); setNotification(''); }
                else { setNotification(msg); setErrorMsg(''); }
                setTimeout(() => { setNotification(''); setErrorMsg(''); }, 3000);
            };

            const loadDirectory = async (path) => {
                setLoading(true);
                try {
                    const response = await fetch(API_URL + '/list', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ path: path || undefined })
                    });
                    const data = await response.json();
                    if (response.ok) {
                        setFiles(data.files);
                        setCurrentPath(data.currentPath);
                        setSelectedItems([]);
                    } else {
                        showNotification(data.error || 'Failed to load directory', true);
                    }
                } catch (error) {
                    showNotification('Server error: ' + error.message, true);
                } finally {
                    setLoading(false);
                }
            };

            const formatFileSize = (bytes) => {
                if (!bytes) return '—';
                if (bytes >= 1073741824) return (bytes / 1073741824).toFixed(2) + ' GB';
                if (bytes >= 1048576) return (bytes / 1048576).toFixed(2) + ' MB';
                if (bytes >= 1024) return (bytes / 1024).toFixed(2) + ' KB';
                return bytes + ' bytes';
            };

            const getFileExtension = (filename) => {
                const ext = filename.split('.').pop().toUpperCase();
                return ext !== filename.toUpperCase() ? ext : 'File';
            };

            const handleNavigate = (path) => { loadDirectory(path); };
            const handleParentDirectory = () => {
                if (!currentPath) return;
                
                // Detect path separator (Windows uses \\ or /, Linux/Mac uses /)
                const isWindows = currentPath.includes('\\\\');
                const separator = isWindows ? '\\\\' : '/';
                
                // Split path and remove last part
                const parts = currentPath.split(isWindows ? /\\\\+/ : /\\/+/);
                const filteredParts = parts.filter(p => p); // Remove empty parts
                
                if (filteredParts.length <= 1) {
                    // Already at root or drive letter
                    if (isWindows && currentPath.match(/^[A-Za-z]:\\\\/)) {
                        // Already at drive root like C:\\
                        showNotification('Already at root directory', true);
                        return;
                    }
                    handleNavigate('/');
                    return;
                }
                
                // Remove last part and rejoin
                filteredParts.pop();
                let parentPath = filteredParts.join(separator);
                
                // Handle Windows drive letter
                if (isWindows && !parentPath.match(/^[A-Za-z]:/)) {
                    parentPath = filteredParts[0] + ':' + separator + filteredParts.slice(1).join(separator);
                } else if (isWindows && filteredParts.length === 1) {
                    parentPath = filteredParts[0] + ':' + separator;
                } else if (!isWindows && !parentPath.startsWith('/')) {
                    parentPath = '/' + parentPath;
                }
                
                handleNavigate(parentPath);
            };

            const handleFileClick = async (item) => {
                if (item.type === 'folder') {
                    // Build path correctly for both Windows and Linux
                    const isWindows = currentPath.includes('\\\\');
                    const separator = isWindows ? '\\\\' : '/';
                    let newPath;
                    
                    if (currentPath.endsWith(separator)) {
                        newPath = currentPath + item.name;
                    } else {
                        newPath = currentPath + separator + item.name;
                    }
                    
                    handleNavigate(newPath);
                } else {
                    try {
                        const response = await fetch(API_URL + '/read', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({ parent: currentPath, name: item.name })
                        });
                        const data = await response.json();
                        if (response.ok) {
                            setViewingFile({ ...item, content: data.content });
                        } else {
                            showNotification(data.error || 'Failed to read file', true);
                        }
                    } catch (error) {
                        showNotification('Error: ' + error.message, true);
                    }
                }
            };

            const handleCreateFile = async () => {
                if (!newFileName.trim()) { showNotification('Please enter a file name', true); return; }
                try {
                    const response = await fetch(API_URL + '/create-file', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ parent: currentPath, name: newFileName })
                    });
                    const data = await response.json();
                    if (response.ok) { 
                        const filePath = currentPath + (currentPath.endsWith('/') || currentPath.endsWith('\\\\') ? '' : '/') + newFileName;
                        setNewFileName(''); 
                        showNotification('✅ File created at: ' + filePath); 
                        loadDirectory(currentPath); 
                    }
                    else { showNotification(data.error || 'Failed to create file', true); }
                } catch (error) { showNotification('Error: ' + error.message, true); }
            };

            const handleCreateFolder = async () => {
                if (!newFolderName.trim()) { showNotification('Please enter a folder name', true); return; }
                try {
                    const response = await fetch(API_URL + '/create-folder', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ parent: currentPath, name: newFolderName })
                    });
                    const data = await response.json();
                    if (response.ok) { 
                        const folderPath = currentPath + (currentPath.endsWith('/') || currentPath.endsWith('\\\\') ? '' : '/') + newFolderName;
                        setNewFolderName(''); 
                        showNotification('✅ Folder created at: ' + folderPath); 
                        loadDirectory(currentPath); 
                    }
                    else { showNotification(data.error || 'Failed to create folder', true); }
                } catch (error) { showNotification('Error: ' + error.message, true); }
            };

            const handleEdit = async (item) => {
                try {
                    const response = await fetch(API_URL + '/read', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ parent: currentPath, name: item.name })
                    });
                    const data = await response.json();
                    if (response.ok) { setEditingFile(item); setEditContent(data.content || ''); }
                    else { showNotification(data.error || 'Failed to read file', true); }
                } catch (error) { showNotification('Error: ' + error.message, true); }
            };

            const handleSaveEdit = async () => {
                try {
                    const response = await fetch(API_URL + '/write', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ parent: currentPath, name: editingFile.name, content: editContent })
                    });
                    const data = await response.json();
                    if (response.ok) { setEditingFile(null); showNotification(data.message); loadDirectory(currentPath); }
                    else { showNotification(data.error || 'Failed to save file', true); }
                } catch (error) { showNotification('Error: ' + error.message, true); }
            };

            const handleRename = (item) => { setRenamingItem(item); setRenameValue(item.name); };

            const handleSaveRename = async () => {
                if (!renameValue.trim()) { showNotification('Please enter a valid name', true); return; }
                try {
                    const response = await fetch(API_URL + '/rename', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ parent: currentPath, oldName: renamingItem.name, newName: renameValue })
                    });
                    const data = await response.json();
                    if (response.ok) { setRenamingItem(null); showNotification(data.message); loadDirectory(currentPath); }
                    else { showNotification(data.error || 'Failed to rename', true); }
                } catch (error) { showNotification('Error: ' + error.message, true); }
            };

            const handleDelete = async (item) => {
                if (!confirm(\`Delete \${item.name}?\`)) return;
                try {
                    const response = await fetch(API_URL + '/delete', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ parent: currentPath, name: item.name })
                    });
                    const data = await response.json();
                    if (response.ok) { showNotification(data.message); loadDirectory(currentPath); }
                    else { showNotification(data.error || 'Failed to delete', true); }
                } catch (error) { showNotification('Error: ' + error.message, true); }
            };

            const handleBulkDelete = async () => {
                if (!confirm(\`Delete \${selectedItems.length} items?\`)) return;
                try {
                    const response = await fetch(API_URL + '/bulk-delete', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ parent: currentPath, items: selectedItems })
                    });
                    const data = await response.json();
                    if (response.ok) { setSelectedItems([]); showNotification(data.message); loadDirectory(currentPath); }
                    else { showNotification(data.error || 'Failed to delete', true); }
                } catch (error) { showNotification('Error: ' + error.message, true); }
            };

            const handleChmod = (item) => { setChmodItem(item); setChmodValue(item.permissions); };

            const handleSaveChmod = async () => {
                try {
                    const response = await fetch(API_URL + '/chmod', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ parent: currentPath, name: chmodItem.name, permissions: chmodValue })
                    });
                    const data = await response.json();
                    if (response.ok) { setChmodItem(null); showNotification(data.message); loadDirectory(currentPath); }
                    else { showNotification(data.error || 'Failed to change permissions', true); }
                } catch (error) { showNotification('Error: ' + error.message, true); }
            };

            const handleDownload = async (item) => {
                try {
                    const response = await fetch(API_URL + '/download', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ parent: currentPath, name: item.name })
                    });
                    if (response.ok) {
                        const blob = await response.blob();
                        const url = window.URL.createObjectURL(blob);
                        const a = document.createElement('a');
                        a.href = url;
                        a.download = item.name;
                        document.body.appendChild(a);
                        a.click();
                        window.URL.revokeObjectURL(url);
                        document.body.removeChild(a);
                        showNotification('Download started');
                    } else {
                        const data = await response.json();
                        showNotification(data.error || 'Download failed', true);
                    }
                } catch (error) { showNotification('Error: ' + error.message, true); }
            };

            const copyToClipboard = (text) => {
                navigator.clipboard.writeText(text).then(() => {
                    showNotification('📋 URL copied to clipboard!');
                }).catch(() => {
                    showNotification('Failed to copy URL', true);
                });
            };

            const openInBrowser = (url) => {
                window.open(url, '_blank');
            };

            const handleUpload = async (event) => {
                const file = event.target.files[0];
                if (!file) return;
                const formData = new FormData();
                formData.append('file', file);
                try {
                    const response = await fetch(API_URL + '/upload?path=' + encodeURIComponent(currentPath), {
                        method: 'POST',
                        body: formData
                    });
                    const data = await response.json();
                    if (response.ok) { 
                        const uploadPath = currentPath + (currentPath.endsWith('/') || currentPath.endsWith('\\\\') ? '' : '/') + file.name;
                        showNotification('✅ Uploaded to: ' + uploadPath); 
                        loadDirectory(currentPath); 
                        event.target.value = ''; 
                    }
                    else { showNotification(data.error || 'Upload failed', true); }
                } catch (error) { showNotification('Error: ' + error.message, true); }
            };

            const handleCommand = async () => {
                if (!commandInput.trim()) return;
                try {
                    const response = await fetch(API_URL + '/command', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ command: commandInput, cwd: currentPath })
                    });
                    const data = await response.json();
                    setCommandOutput(data.output || data.error || 'No output');
                    setCommandInput('');
                } catch (error) { setCommandOutput('Error: ' + error.message); }
            };

            const toggleSelectAll = (checked) => {
                if (checked) { setSelectedItems(files.map(f => f.name)); }
                else { setSelectedItems([]); }
            };

            const toggleSelectItem = (name) => {
                if (selectedItems.includes(name)) { setSelectedItems(selectedItems.filter(n => n !== name)); }
                else { setSelectedItems([...selectedItems, name]); }
            };

            if (loading && files.length === 0) {
                return <div className="container"><div className="loading">Loading...</div></div>;
            }

            return (
                <div className="container">
                    <h1>REACT FILE MANAGER - STANDALONE</h1>
                    <p className="subtitle">Single file • No dependencies • Pure Node.js</p>
                    {notification && <div className="alert alert-success">{notification}</div>}
                    {errorMsg && <div className="alert alert-danger">{errorMsg}</div>}
                    <div className="section">
                        <div className="section-title">Current Directory</div>
                        <div className="input-group">
                            <input type="text" value={pathInput} onChange={(e) => setPathInput(e.target.value)}
                                onKeyPress={(e) => e.key === 'Enter' && handleNavigate(pathInput)}
                                placeholder="Enter path (e.g., C:\\xampp\\htdocs or /home/user)..." />
                            <button className="btn" onClick={() => handleNavigate(pathInput)} disabled={loading}>
                                {loading ? 'Loading...' : 'Navigate'}
                            </button>
                        </div>
                    </div>
                    <div className="grid-2">
                        <div className="section">
                            <div className="section-title">Upload File</div>
                            <div className="input-group">
                                <input type="file" onChange={handleUpload} disabled={loading} />
                            </div>
                            <p style={{fontSize:'11px',color:'#9ca3af',marginTop:'6px'}}>📤 Files will be uploaded to current directory</p>
                        </div>
                        <div className="section">
                            <div className="section-title">Create New</div>
                            <div className="input-group">
                                <input type="text" value={newFileName} onChange={(e) => setNewFileName(e.target.value)}
                                    onKeyPress={(e) => e.key === 'Enter' && handleCreateFile()}
                                    placeholder="File name..." disabled={loading} />
                                <button className="btn btn-primary" onClick={handleCreateFile} disabled={loading}>File</button>
                            </div>
                            <div className="input-group">
                                <input type="text" value={newFolderName} onChange={(e) => setNewFolderName(e.target.value)}
                                    onKeyPress={(e) => e.key === 'Enter' && handleCreateFolder()}
                                    placeholder="Folder name..." disabled={loading} />
                                <button className="btn btn-primary" onClick={handleCreateFolder} disabled={loading}>Folder</button>
                            </div>
                            <p style={{fontSize:'11px',color:'#9ca3af',marginTop:'6px'}}>📝 Items will be created in current directory</p>
                        </div>
                    </div>
                    {editingFile && (
                        <div className="section">
                            <div className="section-title">Editing: {editingFile.name}</div>
                            <textarea value={editContent} onChange={(e) => setEditContent(e.target.value)} />
                            <div style={{marginTop:'12px'}}>
                                <button className="btn btn-primary" onClick={handleSaveEdit}>Save</button>
                                <button className="btn" onClick={() => setEditingFile(null)} style={{marginLeft:'8px'}}>Cancel</button>
                            </div>
                        </div>
                    )}
                    <div className="section">
                        <div className="section-title">Terminal</div>
                        <div className="input-group">
                            <input type="text" value={commandInput} onChange={(e) => setCommandInput(e.target.value)}
                                onKeyPress={(e) => e.key === 'Enter' && handleCommand()}
                                placeholder="Command..." disabled={loading} />
                            <button className="btn btn-primary" onClick={handleCommand} disabled={loading}>Execute</button>
                        </div>
                        {commandOutput && <div className="terminal-output">{commandOutput}</div>}
                    </div>
                    <button className="btn" onClick={handleParentDirectory} style={{marginBottom:'12px'}} disabled={loading || !currentPath} title={!currentPath ? 'Loading directory...' : 'Go to parent directory'}>
                        ← Parent Directory
                    </button>
                    {selectedItems.length > 0 && (
                        <div className="bulk-actions">
                            <span className="bulk-actions-text">{selectedItems.length} item(s) selected</span>
                            <button className="btn btn-danger btn-sm" onClick={handleBulkDelete} disabled={loading}>Delete Selected</button>
                        </div>
                    )}
                    {files.length === 0 && !loading && <div className="alert alert-info">Directory is empty or cannot be accessed</div>}
                    {files.length > 0 && (
                        <table>
                            <thead>
                                <tr>
                                    <th style={{width:'40px'}}>
                                        <input type="checkbox" onChange={(e) => toggleSelectAll(e.target.checked)}
                                            checked={selectedItems.length === files.length && files.length > 0} />
                                    </th>
                                    <th>Name</th>
                                    <th style={{width:'120px'}}>Type</th>
                                    <th style={{width:'100px',textAlign:'right'}}>Size</th>
                                    <th style={{width:'160px'}}>Modified</th>
                                    <th style={{width:'80px',textAlign:'center'}}>Permission</th>
                                    <th style={{width:'200px'}}>Web URL</th>
                                    <th style={{textAlign:'right'}}>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                {files.map(item => (
                                    <tr key={item.id}>
                                        <td>
                                            <input type="checkbox" checked={selectedItems.includes(item.name)}
                                                onChange={() => toggleSelectItem(item.name)} />
                                        </td>
                                        <td>
                                            {renamingItem?.id === item.id ? (
                                                <div style={{display:'flex',gap:'6px'}}>
                                                    <input type="text" value={renameValue} onChange={(e) => setRenameValue(e.target.value)}
                                                        onKeyPress={(e) => e.key === 'Enter' && handleSaveRename()} style={{flex:1}} />
                                                    <button className="btn btn-primary btn-sm" onClick={handleSaveRename}>Save</button>
                                                    <button className="btn btn-sm" onClick={() => setRenamingItem(null)}>Cancel</button>
                                                </div>
                                            ) : (
                                                <div className="file-name" onClick={() => handleFileClick(item)}>
                                                    <span className="file-icon">{item.type === 'folder' ? '📁' : '📄'}</span>
                                                    {item.name}
                                                </div>
                                            )}
                                        </td>
                                        <td>{item.type === 'folder' ? 'Directory' : getFileExtension(item.name)}</td>
                                        <td style={{textAlign:'right'}}>{formatFileSize(item.size)}</td>
                                        <td>{item.modified}</td>
                                        <td style={{textAlign:'center',color:item.writable?'#22c55e':'#ef4444'}}>{item.permissions}</td>
                                        <td>
                                            {item.type === 'file' && item.url ? (
                                                <div style={{display:'flex',gap:'4px',alignItems:'center'}}>
                                                    <span className="url-display" title={item.url}>{item.url}</span>
                                                    <button className="btn btn-url btn-sm" onClick={() => copyToClipboard(item.url)} title="Copy URL">
                                                        📋
                                                    </button>
                                                    <button className="btn btn-url btn-sm" onClick={() => openInBrowser(item.url)} title="Open in new tab">
                                                        🔗
                                                    </button>
                                                </div>
                                            ) : (
                                                <span style={{color:'#6b7280',fontSize:'11px'}}>—</span>
                                            )}
                                        </td>
                                        <td>
                                            <div className="action-buttons">
                                                {item.type === 'file' && <button className="btn btn-sm" onClick={() => handleEdit(item)}>Edit</button>}
                                                <button className="btn btn-sm" onClick={() => handleRename(item)}>Rename</button>
                                                <button className="btn btn-sm" onClick={() => handleChmod(item)}>Chmod</button>
                                                <button className="btn btn-sm" onClick={() => handleDownload(item)}>Download</button>
                                                <button className="btn btn-danger btn-sm" onClick={() => handleDelete(item)}>Delete</button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    )}
                    {viewingFile && (
                        <div className="modal" onClick={() => setViewingFile(null)}>
                            <div className="modal-content" onClick={(e) => e.stopPropagation()}>
                                <div className="modal-header">
                                    <span className="modal-title">Viewing: {viewingFile.name}</span>
                                    <span className="close" onClick={() => setViewingFile(null)}>&times;</span>
                                </div>
                                <textarea readOnly value={viewingFile.content || 'No content'} />
                                <button className="btn" onClick={() => setViewingFile(null)} style={{marginTop:'10px'}}>Close</button>
                            </div>
                        </div>
                    )}
                    {chmodItem && (
                        <div className="modal" onClick={() => setChmodItem(null)}>
                            <div className="modal-content" onClick={(e) => e.stopPropagation()}>
                                <div className="modal-header">
                                    <span className="modal-title">Permissions: {chmodItem.name}</span>
                                    <span className="close" onClick={() => setChmodItem(null)}>&times;</span>
                                </div>
                                <div className="chmod-group">
                                    <label>Octal (e.g., 0755, 0644)</label>
                                    <input type="text" value={chmodValue} onChange={(e) => setChmodValue(e.target.value)} maxLength="4" />
                                </div>
                                <div style={{display:'flex',gap:'8px',marginTop:'10px'}}>
                                    <button className="btn btn-sm" onClick={() => setChmodValue('0755')}>0755</button>
                                    <button className="btn btn-sm" onClick={() => setChmodValue('0644')}>0644</button>
                                    <button className="btn btn-sm" onClick={() => setChmodValue('0777')}>0777</button>
                                </div>
                                <div style={{marginTop:'15px'}}>
                                    <button className="btn btn-primary" onClick={handleSaveChmod}>Apply</button>
                                    <button className="btn" onClick={() => setChmodItem(null)} style={{marginLeft:'8px'}}>Cancel</button>
                                </div>
                            </div>
                        </div>
                    )}
                </div>
            );
        }
        ReactDOM.render(<FileManager />, document.getElementById('root'));
    </script>
</body>
</html>`;

// Parse multipart form data manually (for file uploads)
function parseMultipart(buffer, boundary) {
    const parts = [];
    const boundaryBuffer = Buffer.from('--' + boundary);
    let start = 0;
    
    while (true) {
        const boundaryIndex = buffer.indexOf(boundaryBuffer, start);
        if (boundaryIndex === -1) break;
        
        const headersEnd = buffer.indexOf('\r\n\r\n', boundaryIndex);
        if (headersEnd === -1) break;
        
        const headers = buffer.slice(boundaryIndex, headersEnd).toString();
        const nameMatch = headers.match(/name="([^"]+)"/);
        const filenameMatch = headers.match(/filename="([^"]+)"/);
        
        start = headersEnd + 4;
        const nextBoundary = buffer.indexOf(boundaryBuffer, start);
        const content = nextBoundary === -1 ? buffer.slice(start) : buffer.slice(start, nextBoundary - 2);
        
        if (nameMatch) {
            parts.push({
                name: nameMatch[1],
                filename: filenameMatch ? filenameMatch[1] : null,
                content: content
            });
        }
        
        if (nextBoundary === -1) break;
        start = nextBoundary;
    }
    
    return parts;
}

// Handle HTTP requests
const server = http.createServer((req, res) => {
    const parsedUrl = url.parse(req.url, true);
    const pathname = parsedUrl.pathname;
    
    // Set CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    
    if (req.method === 'OPTIONS') {
        res.writeHead(200);
        res.end();
        return;
    }
    
    // Serve HTML
    if (pathname === '/' || pathname === '/index.html') {
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end(HTML_CONTENT);
        return;
    }
    
    // API endpoints
    let body = [];
    req.on('data', chunk => body.push(chunk));
    req.on('end', async () => {
        body = Buffer.concat(body);
        
        try {
            // List directory
            if (pathname === '/api/list') {
                const data = JSON.parse(body.toString());
                const dirPath = data.path || process.cwd();
                
                if (!fs.existsSync(dirPath)) {
                    res.writeHead(404, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ error: 'Directory not found' }));
                    return;
                }
                
                const items = fs.readdirSync(dirPath, { withFileTypes: true });
                const files = [];
                
                items.forEach((item, index) => {
                    try {
                        const fullPath = path.join(dirPath, item.name);
                        const stats = fs.statSync(fullPath);
                        const isDirectory = item.isDirectory();
                        
                        // Calculate web URL
                        let webUrl = '';
                        if (!isDirectory) {
                            const relativePath = fullPath.replace(WEB_ROOT, '').replace(/\\\\/g, '/');
                            webUrl = BASE_URL + relativePath;
                        }
                        
                        files.push({
                            id: index + 1,
                            name: item.name,
                            type: isDirectory ? 'folder' : 'file',
                            parent: dirPath,
                            size: isDirectory ? null : stats.size,
                            modified: stats.mtime.toISOString().replace('T', ' ').substring(0, 19),
                            permissions: (stats.mode & parseInt('777', 8)).toString(8).padStart(4, '0'),
                            writable: true,
                            url: webUrl
                        });
                    } catch (err) {
                        // Skip files that can't be accessed
                    }
                });
                
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ files, currentPath: dirPath }));
            }
            
            // Read file
            else if (pathname === '/api/read') {
                const data = JSON.parse(body.toString());
                const filePath = path.join(data.parent, data.name);
                
                if (!fs.existsSync(filePath)) {
                    res.writeHead(404, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ error: 'File not found' }));
                    return;
                }
                
                const content = fs.readFileSync(filePath, 'utf8');
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ content }));
            }
            
            // Write file
            else if (pathname === '/api/write') {
                const data = JSON.parse(body.toString());
                const filePath = path.join(data.parent, data.name);
                fs.writeFileSync(filePath, data.content, 'utf8');
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ success: true, message: 'File saved' }));
            }
            
            // Create file
            else if (pathname === '/api/create-file') {
                const data = JSON.parse(body.toString());
                const filePath = path.join(data.parent, data.name);
                
                if (fs.existsSync(filePath)) {
                    res.writeHead(400, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ error: 'File already exists' }));
                    return;
                }
                
                fs.writeFileSync(filePath, '', 'utf8');
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ success: true, message: 'File created' }));
            }
            
            // Create folder
            else if (pathname === '/api/create-folder') {
                const data = JSON.parse(body.toString());
                const folderPath = path.join(data.parent, data.name);
                
                if (fs.existsSync(folderPath)) {
                    res.writeHead(400, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ error: 'Folder already exists' }));
                    return;
                }
                
                fs.mkdirSync(folderPath, { recursive: true });
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ success: true, message: 'Folder created' }));
            }
            
            // Rename
            else if (pathname === '/api/rename') {
                const data = JSON.parse(body.toString());
                const oldPath = path.join(data.parent, data.oldName);
                const newPath = path.join(data.parent, data.newName);
                
                if (!fs.existsSync(oldPath)) {
                    res.writeHead(404, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ error: 'Item not found' }));
                    return;
                }
                
                fs.renameSync(oldPath, newPath);
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ success: true, message: 'Renamed successfully' }));
            }
            
            // Delete
            else if (pathname === '/api/delete') {
                const data = JSON.parse(body.toString());
                const itemPath = path.join(data.parent, data.name);
                
                if (!fs.existsSync(itemPath)) {
                    res.writeHead(404, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ error: 'Item not found' }));
                    return;
                }
                
                const stats = fs.statSync(itemPath);
                if (stats.isDirectory()) {
                    fs.rmSync(itemPath, { recursive: true, force: true });
                } else {
                    fs.unlinkSync(itemPath);
                }
                
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ success: true, message: 'Deleted' }));
            }
            
            // Bulk delete
            else if (pathname === '/api/bulk-delete') {
                const data = JSON.parse(body.toString());
                let deleted = 0, failed = 0;
                
                data.items.forEach(itemName => {
                    try {
                        const itemPath = path.join(data.parent, itemName);
                        if (fs.existsSync(itemPath)) {
                            const stats = fs.statSync(itemPath);
                            if (stats.isDirectory()) {
                                fs.rmSync(itemPath, { recursive: true, force: true });
                            } else {
                                fs.unlinkSync(itemPath);
                            }
                            deleted++;
                        } else {
                            failed++;
                        }
                    } catch (err) {
                        failed++;
                    }
                });
                
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ 
                    success: true, 
                    message: `Deleted ${deleted} item(s)${failed > 0 ? ` (Failed: ${failed})` : ''}` 
                }));
            }
            
            // Chmod
            else if (pathname === '/api/chmod') {
                const data = JSON.parse(body.toString());
                const itemPath = path.join(data.parent, data.name);
                
                if (!fs.existsSync(itemPath)) {
                    res.writeHead(404, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ error: 'Item not found' }));
                    return;
                }
                
                const mode = parseInt(data.permissions, 8);
                fs.chmodSync(itemPath, mode);
                
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ success: true, message: 'Permissions changed' }));
            }
            
            // Download
            else if (pathname === '/api/download') {
                const data = JSON.parse(body.toString());
                const itemPath = path.join(data.parent, data.name);
                
                if (!fs.existsSync(itemPath)) {
                    res.writeHead(404, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ error: 'Item not found' }));
                    return;
                }
                
                const stats = fs.statSync(itemPath);
                if (stats.isFile()) {
                    res.writeHead(200, {
                        'Content-Type': 'application/octet-stream',
                        'Content-Disposition': `attachment; filename="${data.name}"`,
                        'Content-Length': stats.size
                    });
                    fs.createReadStream(itemPath).pipe(res);
                } else {
                    res.writeHead(200, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ error: 'Folder download not supported in standalone version' }));
                }
            }
            
            // Upload
            else if (pathname.startsWith('/api/upload')) {
                const contentType = req.headers['content-type'];
                const boundaryMatch = contentType.match(/boundary=(.+)$/);
                
                if (!boundaryMatch) {
                    res.writeHead(400, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ error: 'Invalid upload' }));
                    return;
                }
                
                const boundary = boundaryMatch[1];
                const parts = parseMultipart(body, boundary);
                const uploadPath = parsedUrl.query.path || process.cwd();
                
                parts.forEach(part => {
                    if (part.filename) {
                        const filePath = path.join(uploadPath, part.filename);
                        fs.writeFileSync(filePath, part.content);
                    }
                });
                
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ success: true, message: 'File uploaded' }));
            }
            
            // Execute command
            else if (pathname === '/api/command') {
                const data = JSON.parse(body.toString());
                const command = data.command;
                const cwd = data.cwd || process.cwd();
                
                exec(command, { cwd, timeout: 10000 }, (error, stdout, stderr) => {
                    res.writeHead(200, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ output: stdout || stderr || error?.message || 'No output' }));
                });
            }
            
            else {
                res.writeHead(404, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ error: 'Not found' }));
            }
        } catch (error) {
            res.writeHead(500, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ error: error.message }));
        }
    });
});

server.listen(PORT, "0.0.0.0", () => {
    console.log(`✅ File Manager Server running on http://localhost:${PORT}`);
    console.log(`📁 Starting directory: ${process.cwd()}`);
    console.log(`🛑 Press Ctrl+C to stop`);
});
