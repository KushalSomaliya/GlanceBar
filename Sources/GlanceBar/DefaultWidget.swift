enum DefaultWidget {
    static let html = ##"""
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          * { box-sizing: border-box; margin: 0; padding: 0; }

          :root {
            --card-bg: rgba(30, 30, 30, 0.7);
            --card-border: rgba(255,255,255,0.08);
            --card-shadow: 0 8px 32px rgba(0,0,0,0.4);
            --text: #f5f5f5;
            --text-title: rgba(255,255,255,0.98);
            --text-muted: rgba(255,255,255,0.75);
            --text-dim: rgba(255,255,255,0.5);
            --text-dimmer: rgba(255,255,255,0.3);
            --hover-bg: rgba(255,255,255,0.07);
            --active-bg: rgba(255,255,255,0.12);
            --input-bg: rgba(255,255,255,0.1);
            --input-border: rgba(255,255,255,0.15);
            --input-focus-bg: rgba(255,255,255,0.12);
            --sep: rgba(255,255,255,0.05);
            --menu-bg: rgba(30,30,30,0.98);
            --menu-border: rgba(255,255,255,0.15);
            --confirm-bg: rgba(40,40,40,0.98);
            --btn-secondary-bg: rgba(255,255,255,0.1);
            --btn-secondary-text: rgba(255,255,255,0.88);
            --dashed-border: rgba(255,255,255,0.15);
            --dashed-bg: rgba(20, 20, 20, 0.4);
            --dashed-hover-border: rgba(255,255,255,0.3);
            --dashed-hover-bg: rgba(20, 20, 20, 0.6);
            --dashed-text: rgba(255,255,255,0.62);
            --dots-color: rgba(255,255,255,0.38);
            --drag-indicator: #0a84ff;
            --accent: #0a84ff;
            --accent-hover: #0070e0;
            --danger: #ff3b30;
            --danger-text: #ff6961;
            --success: #34c759;
            --handle-color: rgba(255,255,255,0.32);
            --handle-hover: rgba(255,255,255,0.55);
            --footer-text: rgba(255,255,255,0.4);
            --footer-hover: rgba(255,255,255,0.6);
          }

          @media (prefers-color-scheme: light) {
            :root:not([data-theme="dark"]) {
              --card-bg: rgba(255, 255, 255, 0.82);
              --card-border: rgba(0,0,0,0.06);
              --card-shadow: 0 4px 20px rgba(0,0,0,0.1);
              --text: #0a0a0c;
              --text-title: rgba(0,0,0,0.96);
              --text-muted: rgba(0,0,0,0.72);
              --text-dim: rgba(0,0,0,0.5);
              --text-dimmer: rgba(0,0,0,0.28);
              --hover-bg: rgba(0,0,0,0.04);
              --active-bg: rgba(0,0,0,0.08);
              --input-bg: rgba(0,0,0,0.04);
              --input-border: rgba(0,0,0,0.1);
              --input-focus-bg: rgba(0,0,0,0.06);
              --sep: rgba(0,0,0,0.06);
              --menu-bg: rgba(255,255,255,0.98);
              --menu-border: rgba(0,0,0,0.12);
              --confirm-bg: rgba(255,255,255,0.98);
              --btn-secondary-bg: rgba(0,0,0,0.06);
              --btn-secondary-text: rgba(0,0,0,0.82);
              --dashed-border: rgba(0,0,0,0.12);
              --dashed-bg: rgba(255,255,255,0.4);
              --dashed-hover-border: rgba(0,0,0,0.2);
              --dashed-hover-bg: rgba(255,255,255,0.6);
              --dashed-text: rgba(0,0,0,0.55);
              --dots-color: rgba(0,0,0,0.32);
              --handle-color: rgba(0,0,0,0.3);
              --handle-hover: rgba(0,0,0,0.55);
              --footer-text: rgba(0,0,0,0.4);
              --footer-hover: rgba(0,0,0,0.6);
            }
          }

          /* Forced light theme override */
          :root[data-theme="light"] {
            --card-bg: rgba(255, 255, 255, 0.82);
            --card-border: rgba(0,0,0,0.06);
            --card-shadow: 0 4px 20px rgba(0,0,0,0.1);
            --text: #0a0a0c;
            --text-title: rgba(0,0,0,0.96);
            --text-muted: rgba(0,0,0,0.72);
            --text-dim: rgba(0,0,0,0.5);
            --text-dimmer: rgba(0,0,0,0.28);
            --hover-bg: rgba(0,0,0,0.04);
            --active-bg: rgba(0,0,0,0.08);
            --input-bg: rgba(0,0,0,0.04);
            --input-border: rgba(0,0,0,0.1);
            --input-focus-bg: rgba(0,0,0,0.06);
            --sep: rgba(0,0,0,0.06);
            --menu-bg: rgba(255,255,255,0.98);
            --menu-border: rgba(0,0,0,0.12);
            --confirm-bg: rgba(255,255,255,0.98);
            --btn-secondary-bg: rgba(0,0,0,0.06);
            --btn-secondary-text: rgba(0,0,0,0.82);
            --dashed-border: rgba(0,0,0,0.12);
            --dashed-bg: rgba(255,255,255,0.4);
            --dashed-hover-border: rgba(0,0,0,0.2);
            --dashed-hover-bg: rgba(255,255,255,0.6);
            --dashed-text: rgba(0,0,0,0.55);
            --dots-color: rgba(0,0,0,0.32);
            --handle-color: rgba(0,0,0,0.3);
            --handle-hover: rgba(0,0,0,0.55);
            --footer-text: rgba(0,0,0,0.4);
            --footer-hover: rgba(0,0,0,0.6);
          }

          body {
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif;
            background: transparent;
            color: var(--text);
            padding: 48px 12px 12px 12px;
            -webkit-user-select: none; user-select: none;
          }

          /* TAB BAR */
          .tab-bar {
            display: flex; align-items: center;
            margin-bottom: 12px;
            position: relative;
          }
          .tab-bar-tabs {
            display: flex; align-items: center; justify-content: center;
            gap: 4px; flex: 1;
            overflow-x: auto;
          }
          .tab-bar-tabs::-webkit-scrollbar { display: none; }
          .tab {
            padding: 4px 14px; border-radius: 7px;
            font-size: 11px; font-weight: 500;
            color: var(--text-dim); cursor: pointer;
            border: none; background: none;
            font-family: inherit; white-space: nowrap;
            transition: all 0.15s;
          }
          .tab:hover { color: var(--text-muted); }
          .tab.active {
            background: var(--accent); color: white;
            box-shadow: 0 2px 8px rgba(10,132,255,0.3);
          }
          .tab-add {
            padding: 4px 8px; border-radius: 6px;
            font-size: 14px; color: var(--text-dim);
            cursor: pointer; border: none; background: none;
            font-family: inherit; transition: all 0.15s;
            flex-shrink: 0; position: absolute; right: 0;
          }
          .tab-add:hover { color: var(--text-muted); }

          .tab-rename-input {
            background: var(--input-bg); border: 1px solid var(--accent);
            border-radius: 6px; padding: 4px 10px; font-size: 11px;
            color: var(--text); outline: none; font-family: inherit;
            width: 80px; -webkit-user-select: text; user-select: text;
            text-align: center;
          }

          /* ANIMATIONS */
          @keyframes fadeSlideIn { from { opacity: 0; transform: translateY(6px); } to { opacity: 1; transform: translateY(0); } }
          @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
          @keyframes scaleIn { from { opacity: 0; transform: scale(0.96); } to { opacity: 1; transform: scale(1); } }

          .card {
            position: relative;
            background: var(--card-bg);
            backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
            border-radius: 14px;
            border: 1px solid var(--card-border);
            padding: 14px;
            box-shadow: var(--card-shadow);
            margin-bottom: 10px;
            animation: scaleIn 0.25s ease;
          }
          .card:has(.row:hover) { z-index: 10; }

          .card-header { display: flex; align-items: center; margin-bottom: 10px; }
          .card-title { font-size: 13px; font-weight: 600; color: var(--text-title); flex: 1; letter-spacing: 0.02em; }
          .card-menu-btn {
            width: 24px; height: 24px; border: none; background: none;
            color: var(--text-dim); font-size: 16px; cursor: pointer;
            border-radius: 6px;
            display: flex; align-items: center; justify-content: center;
            transition: all 0.15s;
          }
          .card-menu-btn:hover { background: var(--hover-bg); color: var(--text-muted); }

          .section { margin-bottom: 8px; animation: fadeSlideIn 0.2s ease; }
          .section:last-child { margin-bottom: 0; }
          .section-nested { margin-left: 12px; padding-left: 8px; border-left: 1px solid var(--sep); }
          .section-header {
            display: flex; align-items: center;
            padding-bottom: 4px;
            border-bottom: 1px solid var(--sep);
            margin-bottom: 3px;
          }
          .section-title { font-size: 9px; font-weight: 600; letter-spacing: 0.08em; text-transform: uppercase; color: var(--text-dim); flex: 1; }
          .section-add-group {
            display: flex; align-items: center;
            opacity: 0; transition: opacity 0.08s;
            position: relative;
          }
          .section-header:hover .section-add-group { opacity: 1; }
          .section-add-btn {
            width: 18px; height: 18px; border: none; background: none;
            color: var(--text-dim); font-size: 15px; cursor: pointer;
            border-radius: 4px 0 0 4px; line-height: 1;
            display: flex; align-items: center; justify-content: center;
            transition: all 0.15s;
          }
          .section-add-btn:hover { background: var(--hover-bg); color: var(--text-muted); }
          .section-dropdown-btn {
            width: 18px; height: 18px; border: none; background: none;
            color: var(--text-dim); font-size: 15px; cursor: pointer;
            border-radius: 0 4px 4px 0; line-height: 1;
            display: flex; align-items: center; justify-content: center;
            transition: all 0.15s;
          }
          .section-dropdown-btn:hover { background: var(--hover-bg); color: var(--text-muted); }

          .row {
            position: relative;
            display: flex; align-items: center;
            padding: 5px 8px; border-radius: 6px;
            cursor: pointer; transition: background 0.08s;
            animation: fadeSlideIn 0.2s ease;
            border: 2px solid transparent;
          }
          .row:hover { background: var(--hover-bg); }
          .row:active { background: var(--active-bg); }

          /* Drag handle */
          .drag-handle {
            width: 14px; margin-right: 4px;
            color: var(--handle-color); font-size: 10px;
            cursor: grab; opacity: 0; transition: opacity 0.08s;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
          }
          .row:hover .drag-handle { opacity: 1; }
          .drag-handle:active { cursor: grabbing; color: var(--handle-hover); }
          .row.dragging { opacity: 0.4; }
          .row.drag-over-top { border-top-color: var(--drag-indicator); }
          .row.drag-over-bottom { border-bottom-color: var(--drag-indicator); }

          .label { color: var(--text-muted); font-size: 12px; flex: 1; }
          .recent-source { font-size: 10px; opacity: 0.75; margin-left: 5px; font-style: italic; font-weight: 400; }

          @keyframes actionSpin { to { transform: rotate(360deg); } }
          .value-run {
            display: inline-flex; align-items: center; justify-content: center;
            position: relative;
            min-width: 58px; height: 20px;
            padding: 0 10px;
            font-size: 10px; font-weight: 600; letter-spacing: 0.05em;
            color: var(--accent);
            background: rgba(10, 132, 255, 0.12);
            border: 1px solid rgba(10, 132, 255, 0.3);
            border-radius: 999px;
            transition: background 0.25s ease, color 0.25s ease, border-color 0.25s ease, transform 0.08s ease;
            user-select: none; -webkit-user-select: none;
          }
          .row-action:hover .value-run { background: rgba(10, 132, 255, 0.22); border-color: rgba(10, 132, 255, 0.5); }
          .row-action:active .value-run { transform: scale(0.95); }
          .row-action.running { pointer-events: none; }
          .row-action.running .value-run { color: transparent; background: rgba(10, 132, 255, 0.08); }
          .value-run.copied {
            color: var(--success) !important;
            background: rgba(52, 199, 89, 0.18) !important;
            border-color: rgba(52, 199, 89, 0.55) !important;
          }
          .row-action.running .value-run::after {
            content: ''; position: absolute;
            width: 11px; height: 11px;
            border: 1.5px solid rgba(10, 132, 255, 0.3);
            border-top-color: var(--accent);
            border-radius: 50%;
            animation: actionSpin 0.7s linear infinite;
          }
          .action-command-field { font-family: 'SF Mono', Menlo, monospace !important; font-size: 11px !important; }
          .value {
            font-size: 11px; font-family: 'SF Mono', Menlo, monospace;
            color: var(--text-muted); transition: color 0.08s;
            max-width: 55%; text-align: right;
            overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
          }
          .row:hover .value { color: var(--text-title); }
          .value.copied { color: var(--success) !important; font-family: -apple-system, sans-serif; font-weight: 500; }

          /* Full value tooltip on hover for truncated values */
          .row { position: relative; }
          .row-editing {
            background: var(--hover-bg); border-radius: 6px;
            padding: 5px 8px; display: flex; gap: 6px;
            align-items: flex-start; animation: fadeSlideIn 0.15s ease;
          }
          .row-editing input, .row-editing textarea {
            flex: 1; min-width: 40px; background: var(--input-bg);
            border: 1px solid var(--input-border); border-radius: 5px;
            padding: 4px 8px; font-size: 12px; color: var(--text);
            outline: none; font-family: inherit;
            -webkit-user-select: text; user-select: text;
          }
          .row-editing textarea {
            resize: vertical; min-height: 28px; max-height: 100px;
            font-family: 'SF Mono', Menlo, monospace; font-size: 11px; line-height: 1.4;
          }
          .row-editing input:focus, .row-editing textarea:focus { border-color: var(--accent); }
          .section-title-editing {
            display: flex; gap: 6px; align-items: center;
            padding-bottom: 4px; margin-bottom: 3px;
            border-bottom: 1px solid var(--sep);
            animation: fadeSlideIn 0.15s ease;
          }
          .section-title-editing input {
            flex: 1; background: var(--input-bg);
            border: 1px solid var(--input-border); border-radius: 5px;
            padding: 3px 8px; font-size: 9px; font-weight: 600;
            letter-spacing: 0.08em; text-transform: uppercase;
            color: var(--text); outline: none; font-family: inherit;
            -webkit-user-select: text; user-select: text;
          }
          .section-title-editing input:focus { border-color: var(--accent); }
          .value-tooltip {
            display: none; position: absolute;
            right: 8px; top: calc(100% + 4px);
            background: var(--menu-bg); border: 1px solid var(--menu-border);
            border-radius: 8px; padding: 6px 10px;
            font-size: 11px; font-family: 'SF Mono', Menlo, monospace;
            color: var(--text); white-space: pre-wrap; word-break: break-all;
            max-width: 300px; z-index: 50;
            box-shadow: 0 4px 16px rgba(0,0,0,0.3);
            pointer-events: none;
            animation: fadeIn 0.15s ease;
          }
          .row:hover .value-tooltip { display: block; }

          .value-dots { font-size: 11px; color: var(--dots-color); letter-spacing: 2px; }
          .value-real { display: none; }
          .row:hover .value-dots { display: none; }
          .row:hover .value-real { display: inline; }

          /* Select mode */
          .select-checkbox {
            width: 16px; height: 16px; margin-right: 8px; border-radius: 4px;
            border: 1.5px solid var(--text-dim); background: none; cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0; transition: all 0.15s; font-size: 10px; color: transparent;
          }
          .select-checkbox:hover { border-color: var(--text-muted); }
          .select-checkbox.checked { background: var(--accent); border-color: var(--accent); color: white; }
          .section-select-checkbox {
            width: 14px; height: 14px; margin-right: 6px; border-radius: 3px;
            border: 1.5px solid var(--text-dimmer); background: none; cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0; transition: all 0.15s; font-size: 8px; color: transparent;
          }
          .section-select-checkbox:hover { border-color: var(--text-dim); }
          .section-select-checkbox.checked { background: var(--accent); border-color: var(--accent); color: white; }

          .select-bar {
            position: fixed; bottom: 0; left: 0; right: 0;
            background: var(--card-bg); backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
            border-top: 1px solid var(--card-border); padding: 10px 16px;
            display: flex; align-items: center; gap: 8px; z-index: 900;
            animation: fadeSlideIn 0.2s ease;
          }
          .select-bar-text { flex: 1; font-size: 12px; color: var(--text-muted); }
          .select-bar-count { color: var(--accent); font-weight: 600; }

          .btn { padding: 5px 12px; border: none; border-radius: 6px; font-size: 11px; cursor: pointer; font-weight: 500; font-family: inherit; transition: all 0.15s; }
          .btn-primary { background: var(--accent); color: white; }
          .btn-primary:hover { background: var(--accent-hover); }
          .btn-secondary { background: var(--btn-secondary-bg); color: var(--btn-secondary-text); }
          .btn-secondary:hover { opacity: 0.8; }
          .btn-danger { background: var(--danger); color: white; }
          .btn-danger:hover { opacity: 0.9; }

          .inline-form { display: none; padding: 6px 8px; background: var(--hover-bg); border-radius: 6px; margin-top: 4px; }
          .inline-form.show { display: flex; gap: 6px; align-items: center; flex-wrap: wrap; animation: fadeSlideIn 0.2s ease; }
          .inline-form input, .inline-form textarea, .card-form input {
            flex: 1; min-width: 60px; background: var(--input-bg); border: 1px solid var(--input-border);
            border-radius: 6px; padding: 6px 10px; font-size: 12px; color: var(--text);
            outline: none; font-family: inherit; -webkit-user-select: text; user-select: text;
          }
          .inline-form textarea {
            resize: vertical; min-height: 32px; max-height: 120px; line-height: 1.4;
          }
          .inline-form input:focus, .inline-form textarea:focus, .card-form input:focus { border-color: var(--accent); background: var(--input-focus-bg); }
          .inline-form input::placeholder, .inline-form textarea::placeholder, .card-form input::placeholder { color: var(--text-dim); }

          .add-card-btn {
            width: 100%; padding: 12px;
            border: 2px dashed var(--dashed-border); background: var(--dashed-bg);
            color: var(--dashed-text); border-radius: 14px; cursor: pointer;
            font-size: 13px; font-family: inherit; font-weight: 500; transition: all 0.15s;
            display: flex; align-items: center; justify-content: center; gap: 6px;
          }
          .add-card-btn:hover { border-color: var(--dashed-hover-border); color: var(--text-muted); background: var(--dashed-hover-bg); }

          .card-form {
            display: none; background: var(--card-bg);
            backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
            border-radius: 14px; border: 1px solid var(--card-border);
            padding: 14px; box-shadow: var(--card-shadow); margin-bottom: 10px;
          }
          .card-form.show { display: block; animation: scaleIn 0.2s ease; }
          .card-form-title { font-size: 12px; font-weight: 600; color: var(--text-muted); margin-bottom: 10px; }
          .card-form .form-row { display: flex; gap: 6px; margin-bottom: 8px; }
          .card-form .form-actions { display: flex; gap: 6px; justify-content: flex-end; }

          .confirm-overlay {
            position: fixed; top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.5); display: none; z-index: 1100;
            align-items: center; justify-content: center;
          }
          .confirm-overlay.show { display: flex; }
          .confirm-box {
            background: var(--confirm-bg); border: 1px solid var(--menu-border);
            border-radius: 14px; padding: 18px; max-width: 300px; width: 90%;
            box-shadow: 0 12px 40px rgba(0,0,0,0.6); animation: scaleIn 0.2s ease;
          }
          .confirm-title { font-size: 14px; font-weight: 600; color: var(--text-title); margin-bottom: 8px; }
          .confirm-body { font-size: 12px; color: var(--text-muted); margin-bottom: 14px; line-height: 1.5; }
          .confirm-body .item-label { display: block; padding: 3px 0; color: var(--text); border-bottom: 1px solid var(--sep); }
          .confirm-actions { display: flex; gap: 8px; justify-content: flex-end; }

          .context-menu {
            position: fixed; background: var(--menu-bg); border: 1px solid var(--menu-border);
            border-radius: 8px; padding: 4px; box-shadow: 0 8px 24px rgba(0,0,0,0.5);
            z-index: 1000; min-width: 170px; display: none;
          }
          .context-menu.show { display: block; animation: scaleIn 0.15s ease; }
          .context-menu-item {
            padding: 6px 12px; border-radius: 4px; font-size: 12px; cursor: pointer;
            color: var(--text); display: flex; align-items: center; gap: 6px;
          }
          .context-menu-item:hover { background: var(--hover-bg); }
          .context-menu-item.danger { color: var(--danger-text); }
          .context-menu-item.danger:hover { background: rgba(255,59,48,0.1); }
          .context-menu-sep { height: 1px; background: var(--sep); margin: 3px 8px; }
          .context-menu-toggle {
            margin-left: auto; width: 32px; height: 18px; border-radius: 10px;
            background: var(--btn-secondary-bg); position: relative; transition: background 0.2s;
          }
          .context-menu-toggle.on { background: var(--success); }
          .context-menu-toggle::after {
            content: ''; position: absolute; width: 14px; height: 14px; border-radius: 50%;
            background: white; top: 2px; left: 2px; transition: transform 0.2s;
          }
          .context-menu-toggle.on::after { transform: translateX(14px); }

          .footer-links {
            display: flex; justify-content: center; gap: 12px;
            padding: 12px 0 4px; font-size: 10px;
          }
          .footer-link {
            color: var(--footer-text); cursor: pointer;
            border: none; background: none; font-family: inherit; font-size: 10px;
            transition: color 0.15s;
          }
          .footer-link:hover { color: var(--footer-hover); }

          .toast {
            position: fixed; bottom: 20px; left: 50%;
            transform: translateX(-50%) translateY(20px);
            background: rgba(52, 199, 89, 0.95); color: white;
            padding: 6px 16px; border-radius: 20px;
            font-size: 12px; font-weight: 500;
            opacity: 0; transition: all 0.3s ease;
            pointer-events: none; z-index: 1200;
          }
          .toast.show { opacity: 1; transform: translateX(-50%) translateY(0); }

          .update-banner {
            display: none; margin-bottom: 10px;
            background: linear-gradient(135deg, rgba(10,132,255,0.15), rgba(94,92,230,0.15));
            border: 1px solid rgba(10,132,255,0.3);
            border-radius: 10px; padding: 10px 14px;
            animation: fadeSlideIn 0.3s ease;
          }
          .update-banner.show { display: flex; align-items: center; gap: 10px; }
          .update-banner-text { flex: 1; font-size: 12px; color: var(--text); }
          .update-banner-text strong { color: var(--accent); }
          .update-banner-btn {
            padding: 5px 14px; border: none; border-radius: 6px;
            background: var(--accent); color: white;
            font-size: 11px; font-weight: 600; cursor: pointer;
            font-family: inherit; transition: opacity 0.15s;
          }
          .update-banner-btn:hover { opacity: 0.85; }
          .update-banner-close {
            width: 18px; height: 18px; border: none; background: none;
            color: var(--text-dim); font-size: 14px; cursor: pointer;
            border-radius: 4px; display: flex; align-items: center; justify-content: center;
          }
          .update-banner-close:hover { background: var(--hover-bg); color: var(--text-muted); }
        </style>
        </head>
        <body>
          <div class="update-banner" id="updateBanner">
            <div class="update-banner-text">Update <strong id="updateVersion"></strong> available</div>
            <button class="update-banner-btn" onclick="runUpdate()">Update</button>
            <button class="update-banner-close" onclick="dismissUpdate()">&times;</button>
          </div>
          <div id="app"></div>
          <div class="context-menu" id="contextMenu"></div>
          <div class="confirm-overlay" id="confirmOverlay"><div class="confirm-box" id="confirmBox"></div></div>
          <div class="toast" id="toast"></div>

          <script>
            var DEFAULT_DATA = {
              pages: [
                {
                  id: 'page_1', name: 'Main', recents: [],
                  cards: [
                    {
                      id: 'card_1', title: 'Quick Reference', hideValues: false,
                      sections: [
                        { id: 's1', title: 'Wi-Fi', items: [
                          { id: 'i1', label: 'Home Network', value: 'MyWiFi_5G' },
                          { id: 'i2', label: 'Password', value: 'super-secret-password' },
                        ]},
                        { id: 's2', title: 'Addresses', items: [
                          { id: 'i3', label: 'Home', value: '123 Main St, Apt 4B' },
                          { id: 'i4', label: 'Office', value: '456 Work Ave, Floor 3' },
                        ]},
                        { id: 's3', title: 'Misc', items: [
                          { id: 'i5', label: 'Laptop Serial', value: 'C02XG0F1JGH5' },
                          { id: 'i6', label: 'License Key', value: 'XXXX-YYYY-ZZZZ-1234' },
                        ]},
                      ]
                    }
                  ]
                }
              ]
            };

            var data = JSON.parse(JSON.stringify(DEFAULT_DATA));
            var activePageId = null;
            var selectMode = false, selectCardId = null, selected = {};
            var editingItemId = null, editingSectionId = null;

            // Drag state
            var dragType = null, dragCardId = null, dragSectionId = null, dragItemId = null;

            function uid() { return 'id_' + Date.now() + '_' + Math.random().toString(36).slice(2,7); }
            function save() { if (window.GlanceBar) GlanceBar.saveData(data); }
            function activePage() { return data.pages.find(function(p){ return p.id === activePageId; }) || data.pages[0]; }

            // Recursive section finder
            function findSection(sections, sectionId) {
              for (var i = 0; i < sections.length; i++) {
                if (sections[i].id === sectionId) return sections[i];
                if (sections[i].sections) {
                  var found = findSection(sections[i].sections, sectionId);
                  if (found) return found;
                }
              }
              return null;
            }
            function findSectionInCard(cardId, sectionId) {
              var c = activePage().cards.find(function(x){return x.id===cardId;});
              return c ? findSection(c.sections, sectionId) : null;
            }

            // Recursive item finder by id across nested sections
            function findItemInSections(sections, itemId) {
              for (var i = 0; i < sections.length; i++) {
                var s = sections[i];
                if (s.items) {
                  var it = s.items.find(function(x){ return x.id === itemId; });
                  if (it) return { section: s, item: it };
                }
                if (s.sections) {
                  var found = findItemInSections(s.sections, itemId);
                  if (found) return found;
                }
              }
              return null;
            }
            function resolveRecent(page, ref) {
              var card = page.cards.find(function(c){ return c.id === ref.cardId; });
              if (!card) return null;
              var hit = findItemInSections(card.sections, ref.itemId);
              if (!hit) return null;
              return { card: card, section: hit.section, item: hit.item };
            }

            window._onDataLoaded = function(saved) {
              if (!saved) return;
              // Migrate old format: { cards: [...] } → { pages: [{ cards: [...] }] }
              if (saved.cards && !saved.pages) {
                data = { pages: [{ id: uid(), name: 'Main', cards: saved.cards }] };
                save();
              } else if (saved.pages) {
                data = saved;
              }
              data.pages.forEach(function(p){ if (!p.recents) p.recents = []; });
              activePageId = data.pages[0] ? data.pages[0].id : null;
              render();
            };
            function esc(s) { var d = document.createElement('div'); d.textContent = s; return d.innerHTML; }
            function showToast(msg) { var t = document.getElementById('toast'); t.textContent = msg; t.classList.add('show'); setTimeout(function(){ t.classList.remove('show'); }, 1500); }

            // ===== RENDER =====
            function render() {
              if (!activePageId && data.pages.length) activePageId = data.pages[0].id;
              var page = activePage();
              var app = document.getElementById('app');
              var html = renderTabBar();
              if (page) {
                html += '<div class="card recents-card" id="recents-mount" data-card="__recents__" style="display:none">' +
                  '<div class="card-header"><div class="card-title">Recently Copied</div></div>' +
                  '<div id="recents-rows"></div></div>';
                html += page.cards.map(function(card) { return renderCard(card); }).join('');
              }
              html += '<div class="card-form" id="newCardForm" data-form-type="card">' +
                '<div class="form-row"><input id="newCardTitle" placeholder="Card name (e.g. Passwords)"></div>' +
                '<div class="form-row"><input id="newCardSection" placeholder="First section name (e.g. Email)"></div>' +
                '</div>';
              html += '<button class="add-card-btn" onclick="showNewCardForm()">+ Add Card</button>';
              html += '<div class="footer-links">' +
                '<button class="footer-link" onclick="GlanceBar.exportData()">Export</button>' +
                '<span style="color:var(--footer-text)">|</span>' +
                '<button class="footer-link" onclick="GlanceBar.importData()">Import</button></div>';
              if (selectMode) {
                var count = Object.keys(selected).length;
                html += '<div class="select-bar"><span class="select-bar-text"><span class="select-bar-count">' + count + '</span> selected</span>' +
                  '<button class="btn btn-secondary" onclick="exitSelectMode()">Cancel</button>' +
                  '<button class="btn btn-danger" onclick="confirmDeleteSelected()" ' + (count===0?'style="opacity:0.4;pointer-events:none"':'') + '>Delete</button></div>';
              }
              app.innerHTML = html;
              updateRecentsMount();
            }

            function renderTabBar() {
              if (data.pages.length <= 1 && !data.pages[0]) return '';
              var html = '<div class="tab-bar"><div class="tab-bar-tabs">';
              data.pages.forEach(function(p) {
                html += '<button class="tab' + (p.id===activePageId?' active':'') + '" ' +
                  'onclick="switchPage(\'' + p.id + '\')" ' +
                  'oncontextmenu="showTabContextMenu(event,\'' + p.id + '\')">' + esc(p.name) + '</button>';
              });
              html += '</div>';
              html += '<button class="tab-add" onclick="addPage()">+</button>';
              html += '</div>';
              return html;
            }

            function computeRecentSuffixes(resolved) {
              var suffixes = resolved.map(function(){ return ''; });
              var groups = {};
              resolved.forEach(function(x, i){
                var k = (x.res.item.label || '').toLowerCase();
                if (!groups[k]) groups[k] = [];
                groups[k].push(i);
              });
              Object.keys(groups).forEach(function(k){
                var ids = groups[k];
                if (ids.length <= 1) return;
                var cards = ids.map(function(i){ return resolved[i].res.card.title; });
                var uniqueByCard = new Set(cards).size === cards.length;
                ids.forEach(function(i){
                  var card = resolved[i].res.card.title;
                  suffixes[i] = uniqueByCard ? card : card + ' \u203A ' + resolved[i].res.section.title;
                });
              });
              return suffixes;
            }

            function updateRecentsMount() {
              var mount = document.getElementById('recents-mount');
              if (!mount) return;
              var rowsHost = document.getElementById('recents-rows');
              var page = activePage();
              var resolved = [];
              if (page && page.recents && !selectMode) {
                page.recents.forEach(function(r){
                  var res = resolveRecent(page, r);
                  if (res) resolved.push({ ref: r, res: res });
                });
              }
              if (!resolved.length) {
                mount.style.display = 'none';
                if (rowsHost) rowsHost.innerHTML = '';
                return;
              }
              var suffixes = computeRecentSuffixes(resolved);
              rowsHost.innerHTML = resolved.map(function(x, i){
                return renderRow(x.ref.cardId, x.ref.sectionId, x.res.item, x.res.card.hideValues, false, 0, true, suffixes[i]);
              }).join('');
              mount.style.display = '';
            }

            function renderCard(card) {
              var isSel = selectMode && selectCardId === card.id;
              return '<div class="card" data-card="' + card.id + '">' +
                '<div class="card-header"><div class="card-title">' + esc(card.title) + '</div>' +
                '<button class="card-menu-btn" onclick="showCardMenu(event,\'' + card.id + '\')">\u2026</button></div>' +
                card.sections.map(function(s) { return renderSection(card.id, s, card.hideValues, isSel); }).join('') +
                '<div class="card-form" id="newSectionForm_' + card.id + '" data-form-card="' + card.id + '" data-form-type="section">' +
                '<div class="form-row"><input id="newSectionTitle_' + card.id + '" placeholder="New section name"></div></div>' +
                '<div class="card-form" id="renameForm_' + card.id + '" data-form-card="' + card.id + '" data-form-type="rename">' +
                '<div class="form-row"><input id="renameInput_' + card.id + '" placeholder="New name" value="' + esc(card.title) + '"></div></div></div>';
            }

            function renderSection(cardId, section, hideValues, isSel, depth) {
              depth = depth || 0;
              var sc = isSel && selected['sec_' + section.id];
              var nestedClass = depth > 0 ? ' section-nested' : '';
              var childSections = section.sections || [];
              return '<div class="section' + nestedClass + '" data-section="' + section.id + '">' +
                (editingSectionId === section.id ?
                  '<div class="section-title-editing" data-edit-card="' + cardId + '" data-edit-sid="' + section.id + '">' +
                    '<input id="edit_section_' + section.id + '" value="' + esc(section.title) + '">' +
                  '</div>'
                :
                  '<div class="section-header" oncontextmenu="showSectionHeaderMenu(event,\'' + cardId + '\',\'' + section.id + '\')">' +
                  (isSel ? '<div class="section-select-checkbox' + (sc?' checked':'') + '" onclick="toggleSelectSection(\'' + section.id + '\')">' + (sc?'\u2713':'') + '</div>' : '') +
                  '<div class="section-title">' + esc(section.title) + '</div>' +
                  (isSel ? '' :
                    '<div class="section-add-group">' +
                      '<button class="section-add-btn" onclick="showAddEntryForm(\'' + cardId + '\',\'' + section.id + '\')">+</button>' +
                      '<button class="section-dropdown-btn" onclick="showSectionDropdown(event,\'' + cardId + '\',\'' + section.id + '\')">\u25BE</button>' +
                    '</div>') +
                  '</div>') +
                section.items.map(function(item, idx) { return renderRow(cardId, section.id, item, hideValues, isSel, idx); }).join('') +
                '<div class="inline-form" id="entryForm_' + section.id + '" data-form-card="' + cardId + '" data-form-section="' + section.id + '" data-form-type="entry">' +
                '<input id="inp_label_' + section.id + '" placeholder="Label">' +
                '<textarea id="inp_value_' + section.id + '" placeholder="Value" rows="1"></textarea>' +
                '</div>' +
                '<div class="inline-form" id="actionForm_' + section.id + '" data-form-card="' + cardId + '" data-form-section="' + section.id + '" data-form-type="action">' +
                '<input id="act_label_' + section.id + '" placeholder="Action label">' +
                '<textarea id="act_command_' + section.id + '" class="action-command-field" placeholder="Shell command" rows="1"></textarea>' +
                '</div>' +
                childSections.map(function(cs) { return renderSection(cardId, cs, hideValues, isSel, depth + 1); }).join('') +
                '<div class="card-form" id="newSubsectionForm_' + section.id + '" data-form-card="' + cardId + '" data-form-section="' + section.id + '" data-form-type="subsection">' +
                '<div class="form-row"><input id="newSubsectionTitle_' + section.id + '" placeholder="New subsection name"></div></div>' +
                '</div>';
            }

            function renderActionRow(cardId, sectionId, item, isSel, isRecent, recentSuffix) {
              var chk = isSel && selected[item.id];
              var srcHtml = recentSuffix ? '<span class="recent-source">' + esc(recentSuffix) + '</span>' : '';
              var labelHtml = '<span class="label">' + esc(item.label) + srcHtml + '</span>';
              var valHtml = '<span class="value-run">RUN</span>';
              var runningCls = _runningActions[item.id] ? ' running' : '';

              if (isRecent) {
                return '<div class="row row-action recent-row' + runningCls + '" data-card="' + cardId + '" data-section="' + sectionId + '" data-item="' + item.id + '" ' +
                  'onclick="runActionById(this,\'' + cardId + '\',\'' + sectionId + '\',\'' + item.id + '\',true)">' +
                  labelHtml + valHtml + '</div>';
              }
              if (isSel) {
                return '<div class="row row-action' + runningCls + '" onclick="toggleSelectItem(\'' + item.id + '\')">' +
                  '<div class="select-checkbox' + (chk?' checked':'') + '">' + (chk?'\u2713':'') + '</div>' +
                  labelHtml + valHtml + '</div>';
              }
              return '<div class="row row-action' + runningCls + '" draggable="true" data-card="' + cardId + '" data-section="' + sectionId + '" data-item="' + item.id + '" ' +
                'ondragstart="onDragStart(event)" ondragend="onDragEnd(event)" ondragover="onDragOver(event)" ondragleave="onDragLeave(event)" ondrop="onDrop(event)" ' +
                'onclick="runActionById(this,\'' + cardId + '\',\'' + sectionId + '\',\'' + item.id + '\',false)" ' +
                'oncontextmenu="showEntryMenu(event,\'' + cardId + '\',\'' + sectionId + '\',\'' + item.id + '\')">' +
                '<span class="drag-handle">\u2630</span>' +
                labelHtml + valHtml + '</div>';
            }

            function renderRow(cardId, sectionId, item, hideValues, isSel, idx, isRecent, recentSuffix) {
              // Inline editing mode (works for both static and action items)
              if (editingItemId === item.id) {
                var content = item.type === 'action' ? (item.command || '') : (item.value || '');
                var rowsN = Math.min(content.split('\n').length, 4);
                var fieldCls = item.type === 'action' ? ' class="action-command-field"' : '';
                return '<div class="row-editing" data-edit-card="' + cardId + '" data-edit-section="' + sectionId + '" data-edit-item="' + item.id + '">' +
                  '<input id="edit_label_' + item.id + '" value="' + esc(item.label) + '">' +
                  '<textarea id="edit_value_' + item.id + '" rows="' + rowsN + '"' + fieldCls + '>' + esc(content) + '</textarea>' +
                  '</div>';
              }

              if (item.type === 'action') {
                return renderActionRow(cardId, sectionId, item, isSel, isRecent, recentSuffix);
              }

              var chk = isSel && selected[item.id];
              var firstLine = item.value.split('\n')[0];
              var isLong = item.value.length > 30 || item.value.includes('\n');
              var tooltipHtml = isLong && !hideValues ? '<div class="value-tooltip">' + esc(item.value) + '</div>' : '';

              var valHtml;
              if (hideValues) {
                valHtml = '<span class="value-dots">\u2022\u2022\u2022\u2022\u2022\u2022</span><span class="value value-real">' + esc(firstLine) + '</span>';
              } else {
                valHtml = '<span class="value">' + esc(firstLine) + '</span>' + tooltipHtml;
              }
              if (isRecent) {
                var srcHtml = recentSuffix ? '<span class="recent-source">' + esc(recentSuffix) + '</span>' : '';
                return '<div class="row recent-row" data-card="' + cardId + '" data-section="' + sectionId + '" data-item="' + item.id + '" ' +
                  'onclick="copyById(this,\'' + cardId + '\',\'' + sectionId + '\',\'' + item.id + '\',' + hideValues + ',true)">' +
                  '<span class="label">' + esc(item.label) + srcHtml + '</span>' + valHtml + '</div>';
              }
              if (isSel) {
                return '<div class="row" onclick="toggleSelectItem(\'' + item.id + '\')">' +
                  '<div class="select-checkbox' + (chk?' checked':'') + '">' + (chk?'\u2713':'') + '</div>' +
                  '<span class="label">' + esc(item.label) + '</span>' + valHtml + '</div>';
              }
              return '<div class="row" draggable="true" data-card="' + cardId + '" data-section="' + sectionId + '" data-item="' + item.id + '" data-idx="' + idx + '" ' +
                'ondragstart="onDragStart(event)" ondragend="onDragEnd(event)" ondragover="onDragOver(event)" ondragleave="onDragLeave(event)" ondrop="onDrop(event)" ' +
                'onclick="copyById(this,\'' + cardId + '\',\'' + sectionId + '\',\'' + item.id + '\',' + hideValues + ')" ' +
                'oncontextmenu="showEntryMenu(event,\'' + cardId + '\',\'' + sectionId + '\',\'' + item.id + '\')">' +
                '<span class="drag-handle">\u2630</span>' +
                '<span class="label">' + esc(item.label) + '</span>' + valHtml + '</div>';
            }

            // ===== DRAG & DROP =====
            function onDragStart(e) {
              var row = e.currentTarget;
              dragCardId = row.dataset.card;
              dragSectionId = row.dataset.section;
              dragItemId = row.dataset.item;
              row.classList.add('dragging');
              e.dataTransfer.effectAllowed = 'move';
              e.dataTransfer.setData('text/plain', dragItemId);
            }
            function onDragEnd(e) {
              e.currentTarget.classList.remove('dragging');
              clearDragIndicators();
              dragCardId = null; dragSectionId = null; dragItemId = null;
            }
            function onDragOver(e) {
              e.preventDefault();
              var row = e.currentTarget;
              if (row.dataset.section !== dragSectionId || row.dataset.item === dragItemId) return;
              clearDragIndicators();
              var rect = row.getBoundingClientRect();
              var midY = rect.top + rect.height / 2;
              if (e.clientY < midY) row.classList.add('drag-over-top');
              else row.classList.add('drag-over-bottom');
            }
            function onDragLeave(e) { e.currentTarget.classList.remove('drag-over-top', 'drag-over-bottom'); }
            function onDrop(e) {
              e.preventDefault();
              var targetRow = e.currentTarget;
              if (targetRow.dataset.section !== dragSectionId) return;
              var card = activePage().cards.find(function(c){ return c.id === dragCardId; });
              var section = card && findSection(card.sections, dragSectionId);
              if (!section) return;
              var fromIdx = section.items.findIndex(function(i){ return i.id === dragItemId; });
              var toIdx = parseInt(targetRow.dataset.idx);
              var rect = targetRow.getBoundingClientRect();
              if (e.clientY > rect.top + rect.height / 2) toIdx++;
              if (fromIdx === toIdx || fromIdx < 0) return;
              var item = section.items.splice(fromIdx, 1)[0];
              if (toIdx > fromIdx) toIdx--;
              section.items.splice(toIdx, 0, item);
              save(); render();
            }
            function clearDragIndicators() {
              document.querySelectorAll('.drag-over-top,.drag-over-bottom').forEach(function(el) {
                el.classList.remove('drag-over-top', 'drag-over-bottom');
              });
            }

            // ===== COPY =====
            function copyById(row, cardId, sectionId, itemId, isHidden, fromRecents) {
              var sec = findSectionInCard(cardId, sectionId);
              if (!sec) return;
              var item = sec.items.find(function(i){ return i.id === itemId; });
              if (!item) return;
              copyValue(row, item.value, isHidden);
              trackRecent(cardId, sectionId, itemId, fromRecents);
            }
            var _recentsDirty = false;
            function trackRecent(cardId, sectionId, itemId, fromRecents) {
              var page = activePage();
              if (!page) return;
              if (!page.recents) page.recents = [];
              page.recents = page.recents.filter(function(r){ return r.itemId !== itemId; });
              page.recents.unshift({ cardId: cardId, sectionId: sectionId, itemId: itemId });
              if (page.recents.length > 5) page.recents = page.recents.slice(0, 5);
              save();
              if (fromRecents) {
                _recentsDirty = true;
              } else {
                _recentsDirty = false;
                updateRecentsMount();
              }
            }
            window._onPanelShow = function() {
              if (_recentsDirty) { _recentsDirty = false; updateRecentsMount(); }
            };

            // ===== ACTIONS (run shell command, copy stdout) =====
            var _runningActions = {};
            var _pendingActions = {};
            window._actionResult = function(id, payload) {
              var p = _pendingActions[id];
              if (!p) return;
              delete _pendingActions[id];
              if (payload && payload.ok) p.resolve(payload.stdout || '');
              else p.reject(payload && payload.error ? payload.error : 'Action failed');
            };
            function runActionPromise(command) {
              return new Promise(function(resolve, reject) {
                var id = 'act_' + Date.now() + '_' + Math.random().toString(36).slice(2,7);
                _pendingActions[id] = { resolve: resolve, reject: reject };
                if (window.GlanceBar && GlanceBar.runAction) GlanceBar.runAction(id, command, 30);
                else { delete _pendingActions[id]; reject('Bridge unavailable'); }
              });
            }
            function runActionById(row, cardId, sectionId, itemId, fromRecents) {
              if (selectMode) { toggleSelectItem(itemId); return; }
              if (_runningActions[itemId]) return;
              var sec = findSectionInCard(cardId, sectionId);
              if (!sec) return;
              var item = sec.items.find(function(i){ return i.id === itemId; });
              if (!item || item.type !== 'action' || !item.command) return;

              _runningActions[itemId] = true;
              document.querySelectorAll('.row[data-item="'+itemId+'"]').forEach(function(el){ el.classList.add('running'); });

              runActionPromise(item.command).then(function(stdout) {
                if (!stdout) {
                  showToast('Action returned empty output');
                  return;
                }
                // Copy to clipboard via existing bridge
                if (window.GlanceBar) GlanceBar.copy(stdout);
                // Animate "Copied" on each visible row for this item
                document.querySelectorAll('.row[data-item="'+itemId+'"]').forEach(function(el){
                  var v = el.querySelector('.value-run');
                  if (!v) return;
                  v.classList.add('copied');
                  randomEffect()(v, 'COPIED', 300, function(){
                    setTimeout(function(){ v.classList.remove('copied'); v.textContent = 'RUN'; }, 900);
                  });
                });
                trackRecent(cardId, sectionId, itemId, fromRecents);
              }).catch(function(err) {
                showToast('Action failed: ' + (err || 'unknown'));
              }).finally(function() {
                delete _runningActions[itemId];
                document.querySelectorAll('.row[data-item="'+itemId+'"]').forEach(function(el){ el.classList.remove('running'); });
              });
            }
            var scrambleChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%&*';
            var matrixChars = '\u30A2\u30AB\u30B5\u30BF\u30CA\u30CF\u30DE\u30E4\u30E9\u30EF01234789';
            var binaryChars = '01';
            var blockChars = '\u2588\u2593\u2592\u2591\u2580\u2584';

            // Effect 1: Decrypt — random chars revealed left to right
            function fxDecrypt(el, finalText, duration, cb) {
              var len = Math.max(finalText.length, 4);
              var steps = 7; var step = 0;
              var t = setInterval(function() {
                step++;
                if (step >= steps) { clearInterval(t); el.textContent = finalText; if(cb)cb(); return; }
                var revealed = Math.floor((step / steps) * len); var r = '';
                for (var i = 0; i < len; i++) r += i < revealed ? (finalText[i]||'') : scrambleChars[Math.floor(Math.random()*scrambleChars.length)];
                el.textContent = r;
              }, duration/steps);
            }

            // Effect 2: Matrix — katakana rain then resolve
            function fxMatrix(el, finalText, duration, cb) {
              var len = Math.max(finalText.length, 5);
              var steps = 8; var step = 0;
              var t = setInterval(function() {
                step++;
                if (step >= steps) { clearInterval(t); el.textContent = finalText; if(cb)cb(); return; }
                var r = '';
                for (var i = 0; i < len; i++) {
                  if (step > steps * 0.6 && i < Math.floor((step/steps)*len)) r += finalText[i]||'';
                  else r += matrixChars[Math.floor(Math.random()*matrixChars.length)];
                }
                el.textContent = r;
              }, duration/steps);
            }

            // Effect 3: Binary — 0s and 1s then snap to final
            function fxBinary(el, finalText, duration, cb) {
              var len = Math.max(finalText.length, 6);
              var steps = 6; var step = 0;
              var t = setInterval(function() {
                step++;
                if (step >= steps) { clearInterval(t); el.textContent = finalText; if(cb)cb(); return; }
                var r = '';
                for (var i = 0; i < len; i++) r += binaryChars[Math.floor(Math.random()*2)];
                el.textContent = r;
              }, duration/steps);
            }

            // Effect 4: Typewriter — one char at a time from left
            function fxTypewriter(el, finalText, duration, cb) {
              var step = 0;
              var t = setInterval(function() {
                step++;
                if (step > finalText.length) { clearInterval(t); if(cb)cb(); return; }
                el.textContent = finalText.slice(0, step);
              }, duration/finalText.length);
            }

            // Effect 5: Blocks — block characters dissolve into text
            function fxBlocks(el, finalText, duration, cb) {
              var len = Math.max(finalText.length, 4);
              var steps = 7; var step = 0;
              var t = setInterval(function() {
                step++;
                if (step >= steps) { clearInterval(t); el.textContent = finalText; if(cb)cb(); return; }
                var r = '';
                for (var i = 0; i < len; i++) {
                  if (Math.random() < step/steps) r += finalText[i]||'';
                  else r += blockChars[Math.floor(Math.random()*blockChars.length)];
                }
                el.textContent = r;
              }, duration/steps);
            }

            // Effect 6: Shuffle — scramble the final text letters then sort into place
            function fxShuffle(el, finalText, duration, cb) {
              var chars = finalText.split('');
              var steps = 7; var step = 0;
              var t = setInterval(function() {
                step++;
                if (step >= steps) { clearInterval(t); el.textContent = finalText; if(cb)cb(); return; }
                var arr = chars.slice();
                var lockCount = Math.floor((step/steps)*arr.length);
                for (var i = arr.length - 1; i >= lockCount; i--) {
                  var j = lockCount + Math.floor(Math.random()*(i-lockCount+1));
                  var tmp = arr[i]; arr[i] = arr[j]; arr[j] = tmp;
                }
                el.textContent = arr.join('');
              }, duration/steps);
            }

            var copyEffects = [fxDecrypt, fxMatrix, fxBinary, fxTypewriter, fxBlocks, fxShuffle];
            function randomEffect() { return copyEffects[Math.floor(Math.random()*copyEffects.length)]; }

            var copyAnimating = {};
            function copyValue(row, text, isHidden) {
              if (selectMode) return;
              var itemId = row.dataset.item || row.dataset.idx || '';
              if (window.GlanceBar) GlanceBar.copy(text);
              else navigator.clipboard.writeText(text).catch(function(){});
              // Skip animation if already animating this row
              if (copyAnimating[itemId]) return;
              var dotsEl = row.querySelector('.value-dots');
              var realEl = row.querySelector('.value-real');
              var plainEl = (!dotsEl) ? row.querySelector('.value') : null;
              var targetEl = realEl || plainEl;
              if (!targetEl) return;
              // Store original from the data, not from DOM
              var firstLine = text.split('\n')[0];
              copyAnimating[itemId] = true;
              if (dotsEl) dotsEl.style.display = 'none';
              if (realEl) realEl.style.display = 'inline';
              targetEl.classList.add('copied');
              randomEffect()(targetEl, 'Copied', 300, function() {
                setTimeout(function(){
                  targetEl.classList.remove('copied');
                  if (dotsEl) { dotsEl.style.display = ''; realEl.style.display = ''; }
                  targetEl.textContent = firstLine;
                  delete copyAnimating[itemId];
                }, 900);
              });
            }

            // ===== SELECT MODE =====
            function enterSelectMode(cardId) { selectMode = true; selectCardId = cardId; selected = {}; hideContextMenu(); render(); }
            function exitSelectMode() { selectMode = false; selectCardId = null; selected = {}; render(); }
            function toggleSelectItem(id) { if (selected[id]) delete selected[id]; else selected[id] = true; render(); }
            function toggleSelectSection(sid) {
              var k = 'sec_' + sid;
              var card = activePage().cards.find(function(c){ return c.id === selectCardId; });
              var sec = card && findSection(card.sections, sid);
              if (!sec) return;
            function selectAllInSection(s, val) {
                s.items.forEach(function(i){ if(val) selected[i.id]=true; else delete selected[i.id]; });
                if (s.sections) s.sections.forEach(function(cs){ if(val) selected['sec_'+cs.id]=true; else delete selected['sec_'+cs.id]; selectAllInSection(cs,val); });
              }
              if (selected[k]) { delete selected[k]; selectAllInSection(sec, false); }
              else { selected[k] = true; selectAllInSection(sec, true); }
              render();
            }
            function collectSelectedLabels(sections, labels, sLabels) {
              sections.forEach(function(s){
                if (selected['sec_'+s.id]) { sLabels.push(s.title+' (entire section)'); }
                else {
                  s.items.forEach(function(i){ if (selected[i.id]) labels.push(i.label); });
                  if (s.sections) collectSelectedLabels(s.sections, labels, sLabels);
                }
              });
            }
            function applyDeleteSelected(sections) {
              sections.forEach(function(s){
                if (selected['sec_'+s.id]) { s.items=[]; s._del=true; }
                else {
                  s.items = s.items.filter(function(i){return !selected[i.id];});
                  if (s.sections) { applyDeleteSelected(s.sections); s.sections = s.sections.filter(function(cs){return !cs._del;}); }
                }
              });
            }
            function confirmDeleteSelected() {
              var card = activePage().cards.find(function(c){ return c.id === selectCardId; });
              if (!card) return;
              var labels = [], sLabels = [];
              collectSelectedLabels(card.sections, labels, sLabels);
              var all = sLabels.concat(labels);
              if (!all.length) return;
              showConfirm('Delete ' + all.length + ' item' + (all.length>1?'s':'') + '?',
                all.map(function(l){ return '<span class="item-label">'+esc(l)+'</span>'; }).join(''),
                function(){
                  applyDeleteSelected(card.sections);
                  card.sections = card.sections.filter(function(s){return !s._del;});
                  save(); exitSelectMode();
                });
            }

            // ===== CONFIRM =====
            function showConfirm(title, body, onOk) {
              var box = document.getElementById('confirmBox');
              box.innerHTML = '<div class="confirm-title">'+title+'</div><div class="confirm-body">'+body+'</div>' +
                '<div class="confirm-actions"><button class="btn btn-secondary" id="cCancel">Cancel</button><button class="btn btn-danger" id="cOk">Delete</button></div>';
              document.getElementById('confirmOverlay').classList.add('show');
              document.getElementById('cCancel').onclick = hideConfirm;
              document.getElementById('cOk').onclick = function(){ hideConfirm(); onOk(); };
            }
            function hideConfirm() { document.getElementById('confirmOverlay').classList.remove('show'); }

            // ===== FORMS =====
            function showAddEntryForm(cid, sid) {
              var form = document.getElementById('entryForm_'+sid);
              form.classList.add('show');
              setTimeout(function(){
                var labelEl = document.getElementById('inp_label_'+sid);
                var valueEl = document.getElementById('inp_value_'+sid);
                labelEl.focus();
                installFormBlur([labelEl, valueEl], function(){ submitEntry(cid, sid); }, function(){ hideAddEntryForm(sid); });
              },50);
            }
            function hideAddEntryForm(sid) {
              var form = document.getElementById('entryForm_'+sid);
              if (form) { form.classList.remove('show'); var inputs = form.querySelectorAll('input,textarea'); inputs.forEach(function(i){i.value='';}); }
            }
            function submitEntry(cid, sid) {
              var l = document.getElementById('inp_label_'+sid).value.trim(), v = document.getElementById('inp_value_'+sid).value.trim();
              if (!l||!v) return;
              var s = findSectionInCard(cid, sid);
              if (s) { s.items.push({id:uid(),label:l,value:v}); save(); render(); }
            }
            function showAddActionForm(cid, sid) {
              var form = document.getElementById('actionForm_'+sid);
              form.classList.add('show');
              setTimeout(function(){
                var labelEl = document.getElementById('act_label_'+sid);
                var cmdEl = document.getElementById('act_command_'+sid);
                labelEl.focus();
                installFormBlur([labelEl, cmdEl], function(){ submitAction(cid, sid); }, function(){ hideAddActionForm(sid); });
              },50);
            }
            function hideAddActionForm(sid) {
              var form = document.getElementById('actionForm_'+sid);
              if (form) { form.classList.remove('show'); var inputs = form.querySelectorAll('input,textarea'); inputs.forEach(function(i){i.value='';}); }
            }
            function submitAction(cid, sid) {
              var l = document.getElementById('act_label_'+sid).value.trim();
              var c = document.getElementById('act_command_'+sid).value.trim();
              if (!l||!c) return;
              var s = findSectionInCard(cid, sid);
              if (s) { s.items.push({id:uid(),type:'action',label:l,command:c}); save(); render(); }
            }
            function showNewSectionForm(cid) {
              hideContextMenu();
              document.getElementById('newSectionForm_'+cid).classList.add('show');
              setTimeout(function(){
                var el = document.getElementById('newSectionTitle_'+cid);
                el.focus();
                installFormBlur([el], function(){ submitNewSection(cid); }, function(){ hideNewSectionForm(cid); });
              },50);
            }
            function hideNewSectionForm(cid) {
              var form = document.getElementById('newSectionForm_'+cid);
              if (form) { form.classList.remove('show'); var inputs = form.querySelectorAll('input'); inputs.forEach(function(i){i.value='';}); }
            }
            function submitNewSection(cid) {
              var t = document.getElementById('newSectionTitle_'+cid).value.trim(); if (!t) return;
              var c = activePage().cards.find(function(x){return x.id===cid;});
              if (c) { c.sections.push({id:uid(),title:t,items:[],sections:[]}); save(); render(); }
            }

            // SUBSECTIONS
            function showSubsectionForm(cid, sid) {
              hideContextMenu();
              document.getElementById('newSubsectionForm_'+sid).classList.add('show');
              setTimeout(function(){
                var el = document.getElementById('newSubsectionTitle_'+sid);
                el.focus();
                installFormBlur([el], function(){ submitSubsection(cid, sid); }, function(){ hideSubsectionForm(sid); });
              },50);
            }
            function hideSubsectionForm(sid) {
              var form = document.getElementById('newSubsectionForm_'+sid);
              if (form) { form.classList.remove('show'); var inputs = form.querySelectorAll('input'); inputs.forEach(function(i){i.value='';}); }
            }
            function submitSubsection(cid, sid) {
              var t = document.getElementById('newSubsectionTitle_'+sid).value.trim(); if (!t) return;
              var s = findSectionInCard(cid, sid);
              if (s) { if (!s.sections) s.sections = []; s.sections.push({id:uid(),title:t,items:[],sections:[]}); save(); render(); }
            }

            // INLINE EDIT
            var editBlurTimeout = null;

            function startEditItem(cid, sid, iid) {
              hideContextMenu();
              editingItemId = iid; editingSectionId = null;
              render();
              setTimeout(function(){
                var labelEl = document.getElementById('edit_label_'+iid);
                var valueEl = document.getElementById('edit_value_'+iid);
                if(labelEl) labelEl.focus();
                installEditBlur([labelEl, valueEl], function(){ trySaveEditItem(cid,sid,iid); });
              }, 50);
            }
            function trySaveEditItem(cid, sid, iid) {
              var labelEl = document.getElementById('edit_label_'+iid);
              var valueEl = document.getElementById('edit_value_'+iid);
              if (!labelEl || !valueEl) return;
              var l = labelEl.value.trim(), v = valueEl.value.trim();
              if (l && v) {
                var sec = findSectionInCard(cid, sid);
                if (sec) {
                  var item = sec.items.find(function(i){return i.id===iid;});
                  if (item) {
                    item.label = l;
                    if (item.type === 'action') item.command = v;
                    else item.value = v;
                  }
                }
                save();
              }
              editingItemId = null; render();
            }
            function startEditSection(cid, sid) {
              hideContextMenu();
              editingSectionId = sid; editingItemId = null;
              render();
              setTimeout(function(){
                var el = document.getElementById('edit_section_'+sid);
                if(el){ el.focus(); el.select(); }
                installEditBlur([el], function(){ trySaveEditSection(cid,sid); });
              }, 50);
            }
            function trySaveEditSection(cid, sid) {
              var el = document.getElementById('edit_section_'+sid);
              if (!el) return;
              var t = el.value.trim();
              if (t) { var sec = findSectionInCard(cid,sid); if(sec) sec.title=t; save(); }
              editingSectionId = null; render();
            }
            function cancelEdit() { window._escCancel = true; editingItemId = null; editingSectionId = null; render(); }

            var formBlurTimeout = null;
            function installFormBlur(elements, saveFn, cancelFn) {
              elements.forEach(function(el){
                if (!el) return;
                el.addEventListener('blur', function(){
                  formBlurTimeout = setTimeout(function(){
                    if (window._escCancel) { window._escCancel = false; cancelFn(); return; }
                    // Check if any of the elements have content
                    var hasContent = elements.some(function(e){ return e && e.value.trim(); });
                    if (hasContent) saveFn();
                    else cancelFn();
                  }, 100);
                });
                el.addEventListener('focus', function(){
                  if (formBlurTimeout) { clearTimeout(formBlurTimeout); formBlurTimeout = null; }
                });
              });
            }

            function installEditBlur(elements, saveFn) {
              elements.forEach(function(el){
                if (!el) return;
                el.addEventListener('blur', function(){
                  editBlurTimeout = setTimeout(function(){
                    if (window._escCancel) { window._escCancel = false; return; }
                    if (editingItemId || editingSectionId) saveFn();
                  }, 100);
                });
                el.addEventListener('focus', function(){
                  if (editBlurTimeout) { clearTimeout(editBlurTimeout); editBlurTimeout = null; }
                });
              });
            }

            // ENTRY CONTEXT MENU (right-click on a row)
            function showEntryMenu(e, cid, sid, iid) {
              e.preventDefault(); e.stopPropagation();
              var m = document.getElementById('contextMenu');
              m.innerHTML =
                '<div class="context-menu-item" onclick="startEditItem(\''+cid+'\',\''+sid+'\',\''+iid+'\')">Edit</div>' +
                '<div class="context-menu-sep"></div>' +
                '<div class="context-menu-item danger" onclick="deleteOneEntry(\''+cid+'\',\''+sid+'\',\''+iid+'\')">Delete</div>';
              m.style.left = Math.min(e.clientX, window.innerWidth-150)+'px';
              m.style.top = (e.clientY+4)+'px';
              m.classList.add('show');
            }
            function deleteOneEntry(cid, sid, iid) {
              hideContextMenu();
              var sec = findSectionInCard(cid, sid);
              if (sec) { sec.items = sec.items.filter(function(i){ return i.id !== iid; }); save(); render(); }
            }

            // SECTION HEADER CONTEXT MENU (right-click on section title)
            function showSectionHeaderMenu(e, cid, sid) {
              e.preventDefault(); e.stopPropagation();
              var m = document.getElementById('contextMenu');
              m.innerHTML =
                '<div class="context-menu-item" onclick="startEditSection(\''+cid+'\',\''+sid+'\')">Rename Section</div>' +
                '<div class="context-menu-item" onclick="showAddEntryForm(\''+cid+'\',\''+sid+'\');hideContextMenu()">Add Entry</div>' +
                '<div class="context-menu-item" onclick="showAddActionForm(\''+cid+'\',\''+sid+'\');hideContextMenu()">Add Action</div>' +
                '<div class="context-menu-item" onclick="showSubsectionForm(\''+cid+'\',\''+sid+'\')">Add Subsection</div>';
              m.style.left = Math.min(e.clientX, window.innerWidth-170)+'px';
              m.style.top = (e.clientY+4)+'px';
              m.classList.add('show');
            }

            // SECTION DROPDOWN (from the small arrow next to +)
            function showSectionDropdown(e, cid, sid) {
              e.stopPropagation();
              var m = document.getElementById('contextMenu');
              m.innerHTML =
                '<div class="context-menu-item" onclick="showAddEntryForm(\''+cid+'\',\''+sid+'\');hideContextMenu()">Add Entry</div>' +
                '<div class="context-menu-item" onclick="showAddActionForm(\''+cid+'\',\''+sid+'\');hideContextMenu()">Add Action</div>' +
                '<div class="context-menu-item" onclick="showSubsectionForm(\''+cid+'\',\''+sid+'\')">Add Subsection</div>';
              var r = e.target.getBoundingClientRect();
              m.style.left = Math.min(r.right - 150, window.innerWidth-160)+'px';
              m.style.top = (r.bottom+4)+'px';
              m.classList.add('show');
            }
            function showNewCardForm() {
              document.getElementById('newCardForm').classList.add('show');
              setTimeout(function(){
                var t = document.getElementById('newCardTitle');
                var s = document.getElementById('newCardSection');
                t.focus();
                installFormBlur([t, s], function(){ submitNewCard(); }, function(){ hideNewCardForm(); });
              },50);
            }
            function hideNewCardForm() {
              var form = document.getElementById('newCardForm');
              if (form) { form.classList.remove('show'); var inputs = form.querySelectorAll('input'); inputs.forEach(function(i){i.value='';}); }
            }
            function submitNewCard() {
              var t = document.getElementById('newCardTitle').value.trim(), s = document.getElementById('newCardSection').value.trim()||'General';
              if (!t) return;
              var page = activePage(); if (!page) return;
              page.cards.push({id:uid(),title:t,hideValues:false,sections:[{id:uid(),title:s,items:[]}]});
              save(); render();
            }
            function showRenameForm(cid) {
              hideContextMenu();
              document.getElementById('renameForm_'+cid).classList.add('show');
              setTimeout(function(){
                var inp = document.getElementById('renameInput_'+cid);
                inp.focus(); inp.select();
                installFormBlur([inp], function(){ submitRename(cid); }, function(){ hideRenameForm(cid); });
              },50);
            }
            function hideRenameForm(cid) {
              var form = document.getElementById('renameForm_'+cid);
              if (form) form.classList.remove('show');
            }
            function submitRename(cid) {
              var t = document.getElementById('renameInput_'+cid).value.trim(); if (!t) return;
              var c = activePage().cards.find(function(x){return x.id===cid;}); if (c) c.title=t;
              save(); render();
            }
            function deleteCard(cid) {
              hideContextMenu();
              var page = activePage(); if (!page) return;
              var c = page.cards.find(function(x){return x.id===cid;}); if (!c) return;
              showConfirm('Delete "'+esc(c.title)+'"?','This will permanently delete this card and all its entries.',function(){
                page.cards=page.cards.filter(function(x){return x.id!==cid;}); save(); render();
              });
            }

            // ===== PAGE MANAGEMENT =====
            function switchPage(pageId) { activePageId = pageId; exitSelectMode(); }
            function addPage() {
              var name = 'Page ' + (data.pages.length + 1);
              var newPage = { id: uid(), name: name, cards: [], recents: [] };
              data.pages.push(newPage);
              activePageId = newPage.id;
              save(); render();
              // Auto-trigger rename so user can name it
              setTimeout(function() {
                var tabs = document.querySelectorAll('.tab.active');
                if (tabs.length) startRenameTabEl(tabs[0], newPage.id);
              }, 50);
            }
            function startRenameTab(e, pageId) {
              e.stopPropagation();
              startRenameTabEl(e.target, pageId);
            }
            function startRenameTabById(pageId) {
              var tabs = document.querySelectorAll('.tab');
              for (var i = 0; i < tabs.length; i++) {
                if (tabs[i].textContent.trim() === (data.pages.find(function(p){return p.id===pageId;}) || {}).name) {
                  startRenameTabEl(tabs[i], pageId);
                  return;
                }
              }
            }
            function startRenameTabEl(tabEl, pageId) {
              var page = data.pages.find(function(p){ return p.id === pageId; });
              if (!page) return;
              var input = document.createElement('input');
              input.className = 'tab-rename-input';
              input.value = page.name;
              input.onblur = function() { finishRenameTab(input, pageId); };
              input.onkeydown = function(ev) {
                if (ev.key === 'Enter') input.blur();
                if (ev.key === 'Escape') { input.value = page.name; input.blur(); }
              };
              tabEl.replaceWith(input);
              input.focus();
              input.select();
            }
            function finishRenameTab(input, pageId) {
              var page = data.pages.find(function(p){ return p.id === pageId; });
              var val = input.value.trim();
              if (val && page) { page.name = val; save(); }
              render();
            }
            function deletePage(pageId) {
              if (data.pages.length <= 1) { showToast('Cannot delete the last page'); return; }
              var page = data.pages.find(function(p){ return p.id === pageId; });
              showConfirm('Delete page "'+esc(page.name)+'"?','This will delete all cards in this page.',function(){
                data.pages = data.pages.filter(function(p){ return p.id !== pageId; });
                if (activePageId === pageId) activePageId = data.pages[0].id;
                save(); render();
              });
            }
            function toggleHideValues(cid) {
              var c = activePage().cards.find(function(x){return x.id===cid;}); if (c) c.hideValues=!c.hideValues;
              save(); render(); hideContextMenu();
            }

            // ===== CONTEXT MENU =====
            function showCardMenu(e, cid) {
              e.stopPropagation();
              var c = activePage().cards.find(function(x){return x.id===cid;});
              var m = document.getElementById('contextMenu');
              m.innerHTML =
                '<div class="context-menu-item" onclick="toggleHideValues(\''+cid+'\')">Hide Values <div class="context-menu-toggle'+(c&&c.hideValues?' on':'')+'"></div></div>' +
                '<div class="context-menu-sep"></div>' +
                '<div class="context-menu-item" onclick="showNewSectionForm(\''+cid+'\')">Add Section</div>' +
                '<div class="context-menu-item" onclick="showRenameForm(\''+cid+'\')">Rename Card</div>' +
                '<div class="context-menu-item" onclick="enterSelectMode(\''+cid+'\')">Select &amp; Delete Items</div>' +
                '<div class="context-menu-sep"></div>' +
                '<div class="context-menu-item danger" onclick="deleteCard(\''+cid+'\')">Delete Card</div>';
              var r = e.target.getBoundingClientRect();
              m.style.left = Math.min(r.left, window.innerWidth-190)+'px';
              m.style.top = (r.bottom+4)+'px';
              m.classList.add('show');
            }
            function showTabContextMenu(e, pageId) {
              e.preventDefault(); e.stopPropagation();
              var page = data.pages.find(function(p){ return p.id === pageId; });
              if (!page) return;
              var m = document.getElementById('contextMenu');
              var html = '<div class="context-menu-item" onclick="startRenameTabById(\''+pageId+'\');hideContextMenu()">Rename</div>';
              if (data.pages.length > 1) {
                html += '<div class="context-menu-sep"></div>';
                html += '<div class="context-menu-item danger" onclick="deletePage(\''+pageId+'\');hideContextMenu()">Delete</div>';
              }
              m.innerHTML = html;
              var r = e.target.getBoundingClientRect();
              m.style.left = Math.min(r.left, window.innerWidth-150)+'px';
              m.style.top = (r.bottom+4)+'px';
              m.classList.add('show');
            }
            function hideContextMenu() { document.getElementById('contextMenu').classList.remove('show'); }

            document.addEventListener('click', function(e) { if (!e.target.closest('.context-menu') && !e.target.closest('.card-menu-btn')) hideContextMenu(); });
            document.addEventListener('keydown', function(e) {
              // Enter in inline edit → save
              if (e.key==='Enter' && (editingItemId || editingSectionId)) {
                if (e.target.tagName==='TEXTAREA' && e.shiftKey) return; // allow shift+enter in textarea
                e.preventDefault();
                var row = e.target.closest('.row-editing');
                var sec = e.target.closest('.section-title-editing');
                if (row) { trySaveEditItem(row.dataset.editCard, row.dataset.editSection, row.dataset.editItem); }
                else if (sec) { trySaveEditSection(sec.dataset.editCard, sec.dataset.editSid); }
                return;
              }
              if (e.key==='Enter' && e.target.tagName==='INPUT') {
                var f=e.target.closest('.inline-form,.card-form');
                if(f){ e.preventDefault(); e.target.blur(); }
              }
              if (e.key==='Enter' && !e.shiftKey && e.target.tagName==='TEXTAREA') {
                var f=e.target.closest('.inline-form,.card-form');
                if(f){ e.preventDefault(); e.target.blur(); }
              }
              if (e.key==='Escape') { if(editingItemId||editingSectionId){cancelEdit();return;} if(selectMode){exitSelectMode();return;} hideConfirm(); }
            });

            // UPDATE BANNER
            window.showUpdateBanner = function(version) {
              document.getElementById('updateVersion').textContent = version;
              document.getElementById('updateBanner').classList.add('show');
            };
            function dismissUpdate() { document.getElementById('updateBanner').classList.remove('show'); }
            function runUpdate() {
              var btn = document.querySelector('.update-banner-btn');
              btn.textContent = 'Updating...';
              btn.style.pointerEvents = 'none';
              btn.style.opacity = '0.6';
              if (window.GlanceBar) window.webkit.messageHandlers.glancebar.postMessage({ action: 'runUpdate' });
            }

            if (data.pages.length) activePageId = data.pages[0].id;
            render();
            setTimeout(function(){ save(); }, 500);
          </script>
        </body>
        </html>
        """##
}
