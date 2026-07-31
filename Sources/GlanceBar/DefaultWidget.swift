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
              --danger-text: #d70015;
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
            --danger-text: #d70015;
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
          .row.search-active,
          .row.search-active:hover { background: var(--active-bg); border-color: var(--accent); }

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

          .value-go {
            display: inline-flex; align-items: center; justify-content: center; gap: 4px;
            position: relative;
            min-width: 58px; height: 20px;
            padding: 0 10px;
            font-size: 10px; font-weight: 600; letter-spacing: 0.05em;
            color: #AF52DE;
            background: rgba(175, 82, 222, 0.12);
            border: 1px solid rgba(175, 82, 222, 0.32);
            border-radius: 999px;
            transition: background 0.25s ease, color 0.25s ease, border-color 0.25s ease, transform 0.08s ease;
            user-select: none; -webkit-user-select: none;
          }
          .value-go .go-glyph { font-size: 8px; line-height: 1; transform: translateY(-0.5px); }
          .row-launch:hover .value-go { background: rgba(175, 82, 222, 0.24); border-color: rgba(175, 82, 222, 0.55); }
          .row-launch:active .value-go { transform: scale(0.95); }
          .row-launch.running { pointer-events: none; }
          .row-launch.running .value-go { color: transparent; background: rgba(175, 82, 222, 0.08); }
          .row-launch.running .value-go::after {
            content: ''; position: absolute;
            width: 11px; height: 11px;
            border: 1.5px solid rgba(175, 82, 222, 0.3);
            border-top-color: #AF52DE;
            border-radius: 50%;
            animation: actionSpin 0.7s linear infinite;
          }
          .value-go.fired {
            color: var(--success) !important;
            background: rgba(52, 199, 89, 0.18) !important;
            border-color: rgba(52, 199, 89, 0.55) !important;
          }
          .value-go.failed {
            color: var(--danger, #ff453a) !important;
            background: rgba(255, 69, 58, 0.18) !important;
            border-color: rgba(255, 69, 58, 0.55) !important;
          }
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
          .toast.toast-error { background: rgba(255, 59, 48, 0.95); }
          .search-wrap { position: relative; display: flex; align-items: center; margin-bottom: 10px; }
          .search-icon { position: absolute; left: 9px; font-size: 13px; color: var(--text-dim); pointer-events: none; }
          .search-wrap input {
            flex: 1; background: var(--input-bg); border: 1px solid var(--input-border);
            border-radius: 8px; padding: 6px 24px 6px 26px; font-size: 12px; color: var(--text);
            outline: none; font-family: inherit; -webkit-user-select: text; user-select: text;
          }
          .search-wrap input:focus { border-color: var(--accent); background: var(--input-focus-bg); }
          .search-wrap input::placeholder { color: var(--text-dim); }
          .search-clear {
            position: absolute; right: 5px; width: 18px; height: 18px; border: none; background: none;
            color: var(--text-dim); font-size: 10px; cursor: pointer; border-radius: 4px;
            display: none; align-items: center; justify-content: center;
          }
          .search-clear:hover { background: var(--hover-bg); color: var(--text-muted); }
          .search-wrap.has-query .search-clear { display: flex; }
          .search-empty { text-align: center; color: var(--text-dim); font-size: 12px; padding: 20px 0 8px; }
        </style>
        </head>
        <body>
          <div class="search-wrap" id="searchWrap">
            <span class="search-icon">&#8981;</span>
            <input id="searchInput" placeholder="Search" autocomplete="off" autocorrect="off" spellcheck="false">
            <button class="search-clear" id="searchClear" tabindex="-1">&#10005;</button>
          </div>
          <div id="app"></div>
          <div class="context-menu" id="contextMenu"></div>
          <div class="confirm-overlay" id="confirmOverlay"><div class="confirm-box" id="confirmBox"></div></div>
          <div class="toast" id="toast"></div>

          <script>
            // Self-heal the bridge: window.GlanceBar is normally injected by
            // the app as a WKUserScript, but the native message handler is
            // registered independently — if the injected object is missing or
            // incomplete (older app binary), rebuild it on top of postMessage
            // so copy/save/actions keep working instead of dying silently.
            (function() {
              var mh = window.webkit && webkit.messageHandlers && webkit.messageHandlers.glancebar;
              if (!mh) return;
              function post(msg) { mh.postMessage(msg); }
              var shim = {
                copy: function(text) { post({ action: 'copy', text: text }); },
                openURL: function(url) { post({ action: 'openURL', url: url }); },
                saveData: function(data) { post({ action: 'saveData', data: JSON.stringify(data) }); },
                exportData: function() { post({ action: 'exportData' }); },
                importData: function() { post({ action: 'importData' }); },
                runAction: function(id, command, timeout) { post({ action: 'runAction', id: id, command: command, timeout: timeout || 30 }); }
              };
              if (!window.GlanceBar) { window.GlanceBar = shim; return; }
              for (var k in shim) { if (!window.GlanceBar[k]) window.GlanceBar[k] = shim[k]; }
            })();

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
            var searchQuery = '';
            var activeSearchItemId = null;

            // Drag state
            var dragType = null, dragCardId = null, dragSectionId = null, dragItemId = null;

            function uid() { return 'id_' + Date.now() + '_' + Math.random().toString(36).slice(2,7); }
            var SAFE_ID_RE = /^[A-Za-z0-9_-]{1,64}$/;
            function isSafeId(id) { return typeof id === 'string' && SAFE_ID_RE.test(id); }

            // Imported data is untrusted. Normalize entity ids before any of
            // them can reach markup or an inline event handler, and keep every
            // stored/live reference aligned with replacements.
            function normalizeDataIds(root) {
              var remap = {
                pages: new Map(), cards: new Map(), sections: new Map(), items: new Map(), changed: false
              };
              var used = new Set();

              function walkSections(sections, visit) {
                (sections || []).forEach(function(section) {
                  visit(section, remap.sections);
                  (section.items || []).forEach(function(item) { visit(item, remap.items); });
                  walkSections(section.sections, visit);
                });
              }
              (root.pages || []).forEach(function(page) {
                if (isSafeId(page.id)) used.add(page.id);
                (page.cards || []).forEach(function(card) {
                  if (isSafeId(card.id)) used.add(card.id);
                  walkSections(card.sections, function(entity) {
                    if (isSafeId(entity.id)) used.add(entity.id);
                  });
                });
              });

              function freshId() {
                var id;
                do { id = uid(); } while (!isSafeId(id) || used.has(id));
                used.add(id);
                return id;
              }
              function normalizeEntity(entity, map) {
                var oldId = entity.id;
                if (isSafeId(oldId)) return;
                if (!map.has(oldId)) map.set(oldId, freshId());
                entity.id = map.get(oldId);
                remap.changed = true;
              }
              function mapped(map, id) { return map.has(id) ? map.get(id) : id; }

              (root.pages || []).forEach(function(page) {
                normalizeEntity(page, remap.pages);
                (page.cards || []).forEach(function(card) {
                  normalizeEntity(card, remap.cards);
                  walkSections(card.sections, normalizeEntity);
                });

                // Canonicalize all three fields from the resolved entities.
                // resolveRecent intentionally finds the real containing
                // section, so a forged/dangling sectionId cannot survive.
                if (page.recents) {
                  page.recents = page.recents.filter(function(ref) {
                    ref.cardId = mapped(remap.cards, ref.cardId);
                    ref.sectionId = mapped(remap.sections, ref.sectionId);
                    ref.itemId = mapped(remap.items, ref.itemId);
                    var resolved = resolveRecent(page, ref);
                    if (!resolved) { remap.changed = true; return false; }
                    if (ref.cardId !== resolved.card.id || ref.sectionId !== resolved.section.id || ref.itemId !== resolved.item.id) {
                      remap.changed = true;
                    }
                    ref.cardId = resolved.card.id;
                    ref.sectionId = resolved.section.id;
                    ref.itemId = resolved.item.id;
                    return true;
                  });
                }
              });
              return remap;
            }

            function remapRuntimeIds(remap) {
              function mappedOrSafe(map, id) {
                if (id === null || typeof id === 'undefined') return id;
                if (map.has(id)) return map.get(id);
                return isSafeId(id) ? id : null;
              }
              activePageId = mappedOrSafe(remap.pages, activePageId);
              selectCardId = mappedOrSafe(remap.cards, selectCardId);
              editingItemId = mappedOrSafe(remap.items, editingItemId);
              editingSectionId = mappedOrSafe(remap.sections, editingSectionId);
              dragCardId = mappedOrSafe(remap.cards, dragCardId);
              dragSectionId = mappedOrSafe(remap.sections, dragSectionId);
              dragItemId = mappedOrSafe(remap.items, dragItemId);

              var nextSelected = {};
              Object.keys(selected || {}).forEach(function(key) {
                var nextKey;
                if (key.indexOf('sec_') === 0) {
                  var sectionId = mappedOrSafe(remap.sections, key.slice(4));
                  if (sectionId !== null) nextKey = 'sec_' + sectionId;
                } else {
                  nextKey = mappedOrSafe(remap.items, key);
                }
                if (nextKey !== null && typeof nextKey !== 'undefined') nextSelected[nextKey] = selected[key];
              });
              selected = nextSelected;

              if (typeof _runningActions !== 'undefined' && _runningActions) {
                var nextRunning = {};
                Object.keys(_runningActions).forEach(function(key) {
                  var nextKey = mappedOrSafe(remap.items, key);
                  if (nextKey !== null) nextRunning[nextKey] = _runningActions[key];
                });
                _runningActions = nextRunning;
              }
            }

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
              var migrated = false;
              // Migrate old format: { cards: [...] } → { pages: [{ cards: [...] }] }
              if (saved.cards && !saved.pages) {
                data = { pages: [{ id: uid(), name: 'Main', cards: saved.cards }] };
                migrated = true;
              } else if (saved.pages) {
                data = saved;
              }
              var idRemap = normalizeDataIds(data);
              remapRuntimeIds(idRemap);
              data.pages.forEach(function(p){ if (!p.recents) p.recents = []; });
              // Legacy rename: 'trigger' → 'launch'
              data.pages.forEach(function(p){ p.cards.forEach(function(c){
                (function walk(secs){ if(!secs) return; secs.forEach(function(s){
                  if (s.items) s.items.forEach(function(i){ if (i.type === 'trigger') i.type = 'launch'; });
                  walk(s.sections);
                }); })(c.sections);
              }); });
              activePageId = data.pages[0] ? data.pages[0].id : null;
              window._dataLoaded = true;
              if (migrated || idRemap.changed) save();
              render();
            };
            function esc(s) { var d = document.createElement('div'); d.textContent = s; return d.innerHTML; }
            // For HTML attribute values (value="...") — esc() doesn't cover quotes
            function escAttr(s) { return esc(s).replace(/"/g, '&quot;'); }
            // JSON supplies JavaScript string quoting; escAttr then protects
            // the surrounding double-quoted HTML handler attribute.
            function escHandlerArg(s) {
              return escAttr(JSON.stringify(String(s)).replace(/\u2028/g, '\\u2028').replace(/\u2029/g, '\\u2029'));
            }
            var _toastTimer = null;
            function showToast(msg, kind) {
              var t = document.getElementById('toast');
              t.textContent = msg;
              t.classList.toggle('toast-error', kind === 'error');
              t.classList.add('show');
              if (_toastTimer) clearTimeout(_toastTimer);
              _toastTimer = setTimeout(function(){ t.classList.remove('show'); }, kind === 'error' ? 2500 : 1500);
            }
            window._saveResult = function(ok, error) {
              try {
                if (ok === true) return;
                var message = (typeof error === 'string' && error.trim()) || 'Failed to save widget data';
                showToast(message, 'error');
              } catch (_) {}
            };

            // ===== SEARCH =====
            function searchQ() { return searchQuery.trim().toLowerCase(); }
            function itemMatches(item, q) {
              if ((item.label || '').toLowerCase().indexOf(q) !== -1) return true;
              var v = (item.type === 'action' || item.type === 'launch') ? item.command : item.value;
              return !!v && v.toLowerCase().indexOf(q) !== -1;
            }
            function sectionMatchCount(s, q) {
              var n = (s.items || []).filter(function(i){ return itemMatches(i, q); }).length;
              (s.sections || []).forEach(function(cs){ n += sectionMatchCount(cs, q); });
              return n;
            }
            function cardMatchCount(card, q) {
              var n = 0;
              card.sections.forEach(function(s){ n += sectionMatchCount(s, q); });
              return n;
            }
            function visibleSearchRows() {
              if (!searchQ()) return [];
              return Array.from(document.querySelectorAll('#app .row[data-item]')).filter(function(row) {
                return row.offsetParent !== null;
              });
            }
            function setActiveSearchRow(itemId, scroll) {
              activeSearchItemId = itemId || null;
              var activeRow = null;
              visibleSearchRows().forEach(function(row) {
                var isActive = !activeRow && row.dataset.item === activeSearchItemId;
                row.classList.toggle('search-active', isActive);
                if (isActive) activeRow = row;
              });
              if (scroll && activeRow) activeRow.scrollIntoView({ block: 'nearest' });
              return activeRow;
            }
            function resetActiveSearchRow() {
              var rows = visibleSearchRows();
              setActiveSearchRow(rows.length ? rows[0].dataset.item : null, false);
            }
            function moveActiveSearchRow(delta) {
              var rows = visibleSearchRows();
              if (!rows.length) { setActiveSearchRow(null, false); return; }
              var index = rows.findIndex(function(row) { return row.dataset.item === activeSearchItemId; });
              if (index < 0) index = delta > 0 ? -1 : 0;
              var next = rows[(index + delta + rows.length) % rows.length];
              setActiveSearchRow(next.dataset.item, true);
            }
            function activateActiveSearchRow() {
              var rows = visibleSearchRows();
              var row = rows.find(function(candidate) { return candidate.dataset.item === activeSearchItemId; }) || rows[0];
              if (row) {
                setActiveSearchRow(row.dataset.item, false);
                row.click();
              }
            }
            function clearSearch() {
              commitPendingEdit();
              searchQuery = '';
              activeSearchItemId = null;
              var input = document.getElementById('searchInput');
              if (input) input.value = '';
              var wrap = document.getElementById('searchWrap');
              if (wrap) wrap.classList.remove('has-query');
              render();
            }
            window._focusSearch = function() {
              var input = document.getElementById('searchInput');
              if (input) { input.focus(); input.select(); }
            };

            // ===== RENDER =====
            function render() {
              commitScheduledBlur();
              if (!activePageId && data.pages.length) activePageId = data.pages[0].id;
              var page = activePage();
              var app = document.getElementById('app');
              var q = searchQ();
              var html = renderTabBar();
              if (page) {
                if (!q) {
                  html += '<div class="card recents-card" id="recents-mount" data-card="__recents__" style="display:none">' +
                    '<div class="card-header" oncontextmenu="showRecentsCardMenu(event)"><div class="card-title">Recently Copied</div></div>' +
                    '<div id="recents-rows"></div></div>';
                }
                var visibleCards = q ? page.cards.filter(function(c){ return cardMatchCount(c, q) > 0; }) : page.cards;
                html += visibleCards.map(function(card) { return renderCard(card); }).join('');
                if (q && !visibleCards.length) html += '<div class="search-empty">No matches</div>';
              }
              html += '<div class="card-form" id="newCardForm" data-form-type="card">' +
                '<div class="form-row"><input id="newCardTitle" placeholder="Card name (e.g. Passwords)"></div>' +
                '<div class="form-row"><input id="newCardSection" placeholder="First section name (e.g. Email)"></div>' +
                '</div>';
              if (!q) {
                html += '<button class="add-card-btn" onclick="showNewCardForm()">+ Add Card</button>';
              }
              html += '<div class="footer-links">' +
                '<button class="footer-link" onclick="GlanceBar.exportData()">Export</button>' +
                '<span style="color:var(--footer-text)">|</span>' +
                '<button class="footer-link" onclick="GlanceBar.importData()">Import</button></div>';
              if (selectMode) {
                var count = Object.keys(selected).length;
                var disabledStyle = count===0?'style="opacity:0.4;pointer-events:none"':'';
                html += '<div class="select-bar"><span class="select-bar-text"><span class="select-bar-count">' + count + '</span> selected</span>' +
                  '<button class="btn btn-secondary" onclick="exitSelectMode()">Cancel</button>' +
                  '<button class="btn btn-secondary" onclick="copySelected()" ' + disabledStyle + '>Copy</button>' +
                  '<button class="btn btn-danger" onclick="confirmDeleteSelected()" ' + disabledStyle + '>Delete</button></div>';
              }
              app.innerHTML = html;
              updateRecentsMount();
              resetActiveSearchRow();
            }

            function renderTabBar() {
              if (data.pages.length <= 1 && !data.pages[0]) return '';
              var html = '<div class="tab-bar"><div class="tab-bar-tabs">';
              data.pages.forEach(function(p) {
                html += '<button class="tab' + (p.id===activePageId?' active':'') + '" ' +
                  'onclick="switchPage(' + escHandlerArg(p.id) + ')" ' +
                  'oncontextmenu="showTabContextMenu(event,' + escHandlerArg(p.id) + ')">' + esc(p.name) + '</button>';
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
              var q = searchQ();
              var sections = q ? card.sections.filter(function(s){ return sectionMatchCount(s, q) > 0; }) : card.sections;
              return '<div class="card" data-card="' + escAttr(card.id) + '">' +
                '<div class="card-header"><div class="card-title">' + esc(card.title) + '</div>' +
                '<button class="card-menu-btn" onclick="showCardMenu(event,' + escHandlerArg(card.id) + ')">\u2026</button></div>' +
                sections.map(function(s) { return renderSection(card.id, s, card.hideValues, isSel); }).join('') +
                '<div class="card-form" id="newSectionForm_' + escAttr(card.id) + '" data-form-card="' + escAttr(card.id) + '" data-form-type="section">' +
                '<div class="form-row"><input id="newSectionTitle_' + escAttr(card.id) + '" placeholder="New section name"></div></div>' +
                '<div class="card-form" id="renameForm_' + escAttr(card.id) + '" data-form-card="' + escAttr(card.id) + '" data-form-type="rename">' +
                '<div class="form-row"><input id="renameInput_' + escAttr(card.id) + '" placeholder="New name" value="' + escAttr(card.title) + '"></div></div></div>';
            }

            function renderSection(cardId, section, hideValues, isSel, depth) {
              depth = depth || 0;
              var sc = isSel && selected['sec_' + section.id];
              var nestedClass = depth > 0 ? ' section-nested' : '';
              var q = searchQ();
              var childSections = section.sections || [];
              if (q) childSections = childSections.filter(function(cs){ return sectionMatchCount(cs, q) > 0; });
              return '<div class="section' + nestedClass + '" data-section="' + escAttr(section.id) + '">' +
                (editingSectionId === section.id ?
                  '<div class="section-title-editing" data-edit-card="' + escAttr(cardId) + '" data-edit-sid="' + escAttr(section.id) + '">' +
                    '<input id="edit_section_' + escAttr(section.id) + '" value="' + escAttr(section.title) + '">' +
                  '</div>'
                :
                  '<div class="section-header" oncontextmenu="showSectionHeaderMenu(event,' + escHandlerArg(cardId) + ',' + escHandlerArg(section.id) + ')">' +
                  (isSel ? '<div class="section-select-checkbox' + (sc?' checked':'') + '" onclick="toggleSelectSection(' + escHandlerArg(section.id) + ')">' + (sc?'\u2713':'') + '</div>' : '') +
                  '<div class="section-title">' + esc(section.title) + '</div>' +
                  (isSel ? '' :
                    '<div class="section-add-group">' +
                      '<button class="section-add-btn" onclick="showAddEntryForm(' + escHandlerArg(cardId) + ',' + escHandlerArg(section.id) + ')">+</button>' +
                      '<button class="section-dropdown-btn" onclick="showSectionDropdown(event,' + escHandlerArg(cardId) + ',' + escHandlerArg(section.id) + ')">\u25BE</button>' +
                    '</div>') +
                  '</div>') +
                section.items.map(function(item, idx) {
                  // Keep the original idx even when filtering so drag/drop
                  // indexes stay consistent with the data array.
                  if (q && !itemMatches(item, q)) return '';
                  return renderRow(cardId, section.id, item, hideValues, isSel, idx);
                }).join('') +
                '<div class="inline-form" id="entryForm_' + escAttr(section.id) + '" data-form-card="' + escAttr(cardId) + '" data-form-section="' + escAttr(section.id) + '" data-form-type="entry">' +
                '<input id="inp_label_' + escAttr(section.id) + '" placeholder="Label">' +
                '<textarea id="inp_value_' + escAttr(section.id) + '" placeholder="Value" rows="1"></textarea>' +
                '</div>' +
                '<div class="inline-form" id="actionForm_' + escAttr(section.id) + '" data-form-card="' + escAttr(cardId) + '" data-form-section="' + escAttr(section.id) + '" data-form-type="action">' +
                '<input id="act_label_' + escAttr(section.id) + '" placeholder="Action label">' +
                '<textarea id="act_command_' + escAttr(section.id) + '" class="action-command-field" placeholder="Shell command" rows="1"></textarea>' +
                '</div>' +
                '<div class="inline-form" id="launchForm_' + escAttr(section.id) + '" data-form-card="' + escAttr(cardId) + '" data-form-section="' + escAttr(section.id) + '" data-form-type="launch">' +
                '<input id="lnc_label_' + escAttr(section.id) + '" placeholder="Launch label">' +
                '<textarea id="lnc_command_' + escAttr(section.id) + '" class="action-command-field" placeholder="~/.glancebar/scripts/your-script.sh" rows="1"></textarea>' +
                '</div>' +
                childSections.map(function(cs) { return renderSection(cardId, cs, hideValues, isSel, depth + 1); }).join('') +
                '<div class="card-form" id="newSubsectionForm_' + escAttr(section.id) + '" data-form-card="' + escAttr(cardId) + '" data-form-section="' + escAttr(section.id) + '" data-form-type="subsection">' +
                '<div class="form-row"><input id="newSubsectionTitle_' + escAttr(section.id) + '" placeholder="New subsection name"></div></div>' +
                '</div>';
            }

            function renderActionRow(cardId, sectionId, item, isSel, idx, isRecent, recentSuffix) {
              var chk = isSel && selected[item.id];
              var srcHtml = recentSuffix ? '<span class="recent-source">' + esc(recentSuffix) + '</span>' : '';
              var labelHtml = '<span class="label">' + esc(item.label) + srcHtml + '</span>';
              var valHtml = '<span class="value-run">RUN</span>';
              var runningCls = _runningActions[item.id] ? ' running' : '';

              if (isRecent) {
                return '<div class="row row-action recent-row' + runningCls + '" data-card="' + escAttr(cardId) + '" data-section="' + escAttr(sectionId) + '" data-item="' + escAttr(item.id) + '" ' +
                  'onclick="runActionById(this,' + escHandlerArg(cardId) + ',' + escHandlerArg(sectionId) + ',' + escHandlerArg(item.id) + ',true)" ' +
                  'oncontextmenu="showRecentMenu(event,' + escHandlerArg(cardId) + ',' + escHandlerArg(sectionId) + ',' + escHandlerArg(item.id) + ')">' +
                  labelHtml + valHtml + '</div>';
              }
              if (isSel) {
                return '<div class="row row-action' + runningCls + '" data-card="' + escAttr(cardId) + '" data-section="' + escAttr(sectionId) + '" data-item="' + escAttr(item.id) + '" ' +
                  'onclick="toggleSelectItem(' + escHandlerArg(item.id) + ')">' +
                  '<div class="select-checkbox' + (chk?' checked':'') + '">' + (chk?'\u2713':'') + '</div>' +
                  labelHtml + valHtml + '</div>';
              }
              return '<div class="row row-action' + runningCls + '" draggable="true" data-card="' + escAttr(cardId) + '" data-section="' + escAttr(sectionId) + '" data-item="' + escAttr(item.id) + '" data-idx="' + idx + '" ' +
                'ondragstart="onDragStart(event)" ondragend="onDragEnd(event)" ondragover="onDragOver(event)" ondragleave="onDragLeave(event)" ondrop="onDrop(event)" ' +
                'onclick="runActionById(this,' + escHandlerArg(cardId) + ',' + escHandlerArg(sectionId) + ',' + escHandlerArg(item.id) + ',false)" ' +
                'oncontextmenu="showEntryMenu(event,' + escHandlerArg(cardId) + ',' + escHandlerArg(sectionId) + ',' + escHandlerArg(item.id) + ')">' +
                '<span class="drag-handle">\u2630</span>' +
                labelHtml + valHtml + '</div>';
            }

            function renderLaunchRow(cardId, sectionId, item, isSel, idx, isRecent, recentSuffix) {
              var chk = isSel && selected[item.id];
              var srcHtml = recentSuffix ? '<span class="recent-source">' + esc(recentSuffix) + '</span>' : '';
              var labelHtml = '<span class="label">' + esc(item.label) + srcHtml + '</span>';
              var valHtml = '<span class="value-go"><span class="go-glyph">\u25B6</span>GO</span>';
              var runningCls = _runningActions[item.id] ? ' running' : '';

              if (isRecent) {
                return '<div class="row row-launch recent-row' + runningCls + '" data-card="' + escAttr(cardId) + '" data-section="' + escAttr(sectionId) + '" data-item="' + escAttr(item.id) + '" ' +
                  'onclick="runLaunchById(this,' + escHandlerArg(cardId) + ',' + escHandlerArg(sectionId) + ',' + escHandlerArg(item.id) + ',true)" ' +
                  'oncontextmenu="showRecentMenu(event,' + escHandlerArg(cardId) + ',' + escHandlerArg(sectionId) + ',' + escHandlerArg(item.id) + ')">' +
                  labelHtml + valHtml + '</div>';
              }
              if (isSel) {
                return '<div class="row row-launch' + runningCls + '" data-card="' + escAttr(cardId) + '" data-section="' + escAttr(sectionId) + '" data-item="' + escAttr(item.id) + '" ' +
                  'onclick="toggleSelectItem(' + escHandlerArg(item.id) + ')">' +
                  '<div class="select-checkbox' + (chk?' checked':'') + '">' + (chk?'\u2713':'') + '</div>' +
                  labelHtml + valHtml + '</div>';
              }
              return '<div class="row row-launch' + runningCls + '" draggable="true" data-card="' + escAttr(cardId) + '" data-section="' + escAttr(sectionId) + '" data-item="' + escAttr(item.id) + '" data-idx="' + idx + '" ' +
                'ondragstart="onDragStart(event)" ondragend="onDragEnd(event)" ondragover="onDragOver(event)" ondragleave="onDragLeave(event)" ondrop="onDrop(event)" ' +
                'onclick="runLaunchById(this,' + escHandlerArg(cardId) + ',' + escHandlerArg(sectionId) + ',' + escHandlerArg(item.id) + ',false)" ' +
                'oncontextmenu="showEntryMenu(event,' + escHandlerArg(cardId) + ',' + escHandlerArg(sectionId) + ',' + escHandlerArg(item.id) + ')">' +
                '<span class="drag-handle">\u2630</span>' +
                labelHtml + valHtml + '</div>';
            }

            function renderRow(cardId, sectionId, item, hideValues, isSel, idx, isRecent, recentSuffix) {
              // Inline editing mode (works for static, action, and launch items).
              // Never rendered inside the Recently Copied mirror — the real row
              // hosts the inputs so their element ids stay unique and the edit
              // opens where the user actually right-clicked.
              if (editingItemId === item.id && !isRecent) {
                var content = (item.type === 'action' || item.type === 'launch') ? (item.command || '') : (item.value || '');
                var rowsN = Math.min(content.split('\n').length, 4);
                var fieldCls = (item.type === 'action' || item.type === 'launch') ? ' class="action-command-field"' : '';
                return '<div class="row-editing" data-edit-card="' + escAttr(cardId) + '" data-edit-section="' + escAttr(sectionId) + '" data-edit-item="' + escAttr(item.id) + '">' +
                  '<input id="edit_label_' + escAttr(item.id) + '" value="' + escAttr(item.label) + '">' +
                  '<textarea id="edit_value_' + escAttr(item.id) + '" rows="' + rowsN + '"' + fieldCls + '>' + esc(content) + '</textarea>' +
                  '</div>';
              }

              if (item.type === 'action') {
                return renderActionRow(cardId, sectionId, item, isSel, idx, isRecent, recentSuffix);
              }
              if (item.type === 'launch') {
                return renderLaunchRow(cardId, sectionId, item, isSel, idx, isRecent, recentSuffix);
              }

              var chk = isSel && selected[item.id];
              var hidden = hideValues || !!item.hide;
              var firstLine = item.value.split('\n')[0];
              var isLong = item.value.length > 30 || item.value.includes('\n');
              // Hidden values are hover-revealed by design, so they get the
              // full-value tooltip too. Suppressed in select mode, where the
              // fixed bottom bar covers it and hover means "selecting".
              var tooltipHtml = isLong && !isSel ? '<div class="value-tooltip">' + esc(item.value) + '</div>' : '';

              var valHtml;
              if (hidden) {
                valHtml = '<span class="value-dots">\u2022\u2022\u2022\u2022\u2022\u2022</span><span class="value value-real">' + esc(firstLine) + '</span>' + tooltipHtml;
              } else {
                valHtml = '<span class="value">' + esc(firstLine) + '</span>' + tooltipHtml;
              }
              if (isRecent) {
                var srcHtml = recentSuffix ? '<span class="recent-source">' + esc(recentSuffix) + '</span>' : '';
                return '<div class="row recent-row" data-card="' + escAttr(cardId) + '" data-section="' + escAttr(sectionId) + '" data-item="' + escAttr(item.id) + '" ' +
                  'onclick="copyById(this,' + escHandlerArg(cardId) + ',' + escHandlerArg(sectionId) + ',' + escHandlerArg(item.id) + ',' + hidden + ',true)" ' +
                  'oncontextmenu="showRecentMenu(event,' + escHandlerArg(cardId) + ',' + escHandlerArg(sectionId) + ',' + escHandlerArg(item.id) + ')">' +
                  '<span class="label">' + esc(item.label) + srcHtml + '</span>' + valHtml + '</div>';
              }
              if (isSel) {
                return '<div class="row" data-card="' + escAttr(cardId) + '" data-section="' + escAttr(sectionId) + '" data-item="' + escAttr(item.id) + '" ' +
                  'onclick="toggleSelectItem(' + escHandlerArg(item.id) + ')">' +
                  '<div class="select-checkbox' + (chk?' checked':'') + '">' + (chk?'\u2713':'') + '</div>' +
                  '<span class="label">' + esc(item.label) + '</span>' + valHtml + '</div>';
              }
              return '<div class="row" draggable="true" data-card="' + escAttr(cardId) + '" data-section="' + escAttr(sectionId) + '" data-item="' + escAttr(item.id) + '" data-idx="' + idx + '" ' +
                'ondragstart="onDragStart(event)" ondragend="onDragEnd(event)" ondragover="onDragOver(event)" ondragleave="onDragLeave(event)" ondrop="onDrop(event)" ' +
                'onclick="copyById(this,' + escHandlerArg(cardId) + ',' + escHandlerArg(sectionId) + ',' + escHandlerArg(item.id) + ',' + hidden + ')" ' +
                'oncontextmenu="showEntryMenu(event,' + escHandlerArg(cardId) + ',' + escHandlerArg(sectionId) + ',' + escHandlerArg(item.id) + ')">' +
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
              // Read the drop target's geometry BEFORE commitPendingEdit —
              // its render() detaches targetRow, zeroing the rect.
              var toIdx = parseInt(targetRow.dataset.idx);
              var rect = targetRow.getBoundingClientRect();
              if (e.clientY > rect.top + rect.height / 2) toIdx++;
              if (isNaN(toIdx)) return;
              commitPendingEdit();
              var card = activePage().cards.find(function(c){ return c.id === dragCardId; });
              var section = card && findSection(card.sections, dragSectionId);
              if (!section) return;
              var fromIdx = section.items.findIndex(function(i){ return i.id === dragItemId; });
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
            var ACTION_TIMEOUT_SECS = 30;
            function runActionPromise(command) {
              return new Promise(function(resolve, reject) {
                var id = 'act_' + Date.now() + '_' + Math.random().toString(36).slice(2,7);
                _pendingActions[id] = { resolve: resolve, reject: reject };
                function fail(msg) { delete _pendingActions[id]; reject(msg); }
                try {
                  if (window.GlanceBar && GlanceBar.runAction) {
                    GlanceBar.runAction(id, command, ACTION_TIMEOUT_SECS);
                  } else if (window.webkit && webkit.messageHandlers && webkit.messageHandlers.glancebar) {
                    // Injected bridge object missing but the native handler is
                    // still registered — post directly.
                    webkit.messageHandlers.glancebar.postMessage({ action: 'runAction', id: id, command: command, timeout: ACTION_TIMEOUT_SECS });
                  } else {
                    fail('Bridge unavailable — quit and reopen GlanceBar');
                    return;
                  }
                } catch (e) {
                  fail('Bridge error — quit and reopen GlanceBar');
                  return;
                }
                // Watchdog: an old app version that doesn't understand
                // runAction would otherwise leave this pending forever.
                setTimeout(function() {
                  if (_pendingActions[id]) fail('No response from GlanceBar — update or restart the app');
                }, (ACTION_TIMEOUT_SECS + 5) * 1000);
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
                showToast('Action failed: ' + (err || 'unknown'), 'error');
              }).finally(function() {
                delete _runningActions[itemId];
                document.querySelectorAll('.row[data-item="'+itemId+'"]').forEach(function(el){ el.classList.remove('running'); });
              });
            }

            // Launch: fire-and-forget. Runs the command, ignores stdout, shows DONE / FAIL feedback.
            function runLaunchById(row, cardId, sectionId, itemId, fromRecents) {
              if (selectMode) { toggleSelectItem(itemId); return; }
              if (_runningActions[itemId]) return;
              var sec = findSectionInCard(cardId, sectionId);
              if (!sec) return;
              var item = sec.items.find(function(i){ return i.id === itemId; });
              if (!item || item.type !== 'launch' || !item.command) return;

              _runningActions[itemId] = true;
              document.querySelectorAll('.row[data-item="'+itemId+'"]').forEach(function(el){ el.classList.add('running'); });

              runActionPromise(item.command).then(function() {
                document.querySelectorAll('.row[data-item="'+itemId+'"]').forEach(function(el){
                  var v = el.querySelector('.value-go');
                  if (!v) return;
                  v.classList.add('fired');
                  randomEffect()(v, 'DONE', 300, function(){
                    setTimeout(function(){
                      v.classList.remove('fired');
                      v.innerHTML = '<span class="go-glyph">\u25B6</span>GO';
                    }, 900);
                  });
                });
                trackRecent(cardId, sectionId, itemId, fromRecents);
              }).catch(function(err) {
                document.querySelectorAll('.row[data-item="'+itemId+'"]').forEach(function(el){
                  var v = el.querySelector('.value-go');
                  if (!v) return;
                  v.classList.add('failed');
                  v.innerHTML = 'FAIL';
                  setTimeout(function(){
                    v.classList.remove('failed');
                    v.innerHTML = '<span class="go-glyph">\u25B6</span>GO';
                  }, 1400);
                });
                showToast('Launch failed: ' + (err || 'unknown'), 'error');
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

            function copyValue(row, text, isHidden) {
              if (selectMode) return;
              if (window.GlanceBar) GlanceBar.copy(text);
              else navigator.clipboard.writeText(text).catch(function(){});
              // Gate the animation per row node — the same item can be on
              // screen twice (original + Recently Copied) and each copy should
              // animate independently.
              if (row._copyAnimating) return;
              var dotsEl = row.querySelector('.value-dots');
              var realEl = row.querySelector('.value-real');
              var plainEl = (!dotsEl) ? row.querySelector('.value') : null;
              var targetEl = realEl || plainEl;
              if (!targetEl) return;
              // Store original from the data, not from DOM
              var firstLine = text.split('\n')[0];
              row._copyAnimating = true;
              if (dotsEl) dotsEl.style.display = 'none';
              if (realEl) realEl.style.display = 'inline';
              targetEl.classList.add('copied');
              randomEffect()(targetEl, 'Copied', 300, function() {
                setTimeout(function(){
                  targetEl.classList.remove('copied');
                  if (dotsEl) { dotsEl.style.display = ''; realEl.style.display = ''; }
                  targetEl.textContent = firstLine;
                  row._copyAnimating = false;
                }, 900);
              });
            }

            // ===== SELECT MODE =====
            function enterSelectMode(cardId) { commitPendingEdit(); selectMode = true; selectCardId = cardId; selected = {}; hideContextMenu(); render(); }
            function exitSelectMode() { selectMode = false; selectCardId = null; selected = {}; render(); }
            // Sections between the card root and an item, innermost last
            function findAncestorSections(sections, itemId, chain) {
              for (var i = 0; i < sections.length; i++) {
                var s = sections[i];
                if (s.items && s.items.some(function(x){ return x.id === itemId; })) return chain.concat([s]);
                if (s.sections) {
                  var found = findAncestorSections(s.sections, itemId, chain.concat([s]));
                  if (found) return found;
                }
              }
              return null;
            }
            function toggleSelectItem(id) {
              if (selected[id]) {
                delete selected[id];
                // Deselecting one item breaks its ancestors' "entire section"
                // selection — otherwise bulk delete would still wipe the whole
                // section, including this item.
                var card = activePage().cards.find(function(c){ return c.id === selectCardId; });
                if (card) {
                  var ancestors = findAncestorSections(card.sections, id, []);
                  if (ancestors) ancestors.forEach(function(s){ delete selected['sec_' + s.id]; });
                }
              } else {
                selected[id] = true;
              }
              render();
            }
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
            function collectSelectedValues(sections, out) {
              sections.forEach(function(s){
                var wholeSection = selected['sec_' + s.id];
                s.items.forEach(function(i){
                  if (wholeSection || selected[i.id]) {
                    var v = (i.type === 'action' || i.type === 'launch') ? i.command : i.value;
                    out.push(i.label + ': ' + (v || ''));
                  }
                });
                if (s.sections) collectSelectedValues(s.sections, out);
              });
            }
            function copySelected() {
              var card = activePage().cards.find(function(c){ return c.id === selectCardId; });
              if (!card) return;
              var lines = [];
              collectSelectedValues(card.sections, lines);
              if (!lines.length) return;
              if (window.GlanceBar) GlanceBar.copy(lines.join('\n'));
              else navigator.clipboard.writeText(lines.join('\n')).catch(function(){});
              showToast('Copied ' + lines.length + ' entr' + (lines.length === 1 ? 'y' : 'ies'));
              exitSelectMode();
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
                  pruneRecents();
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
            document.getElementById('confirmOverlay').addEventListener('click', function(e){
              if (e.target === this) hideConfirm();
            });

            // ===== FORMS =====
            // Multi-line "Label: Value" (or "Label = Value" / tab-separated)
            // pastes into the add-entry label field create one entry per line.
            function parseBulkEntries(text) {
              var out = [];
              text.split('\n').forEach(function(line){
                line = line.trim();
                if (!line) return;
                var m = line.match(/^([^:=\t]+)[:=\t]\s*(.+)$/);
                if (m) out.push({ label: m[1].trim(), value: m[2].trim() });
              });
              return out;
            }
            function installBulkPaste(labelEl, cid, sid) {
              if (!labelEl || labelEl._bulkBound) return;
              labelEl._bulkBound = true;
              labelEl.addEventListener('paste', function(ev){
                var text = ev.clipboardData ? ev.clipboardData.getData('text') : '';
                if (!text || text.indexOf('\n') === -1) return;
                var entries = parseBulkEntries(text);
                if (entries.length < 2) return;
                ev.preventDefault();
                var s = findSectionInCard(cid, sid);
                if (!s) return;
                entries.forEach(function(en){ s.items.push({ id: uid(), label: en.label, value: en.value }); });
                save(); render();
                showToast('Added ' + entries.length + ' entries');
              });
            }
            function showAddEntryForm(cid, sid) {
              var form = document.getElementById('entryForm_'+sid);
              form.classList.add('show');
              setTimeout(function(){
                var labelEl = document.getElementById('inp_label_'+sid);
                var valueEl = document.getElementById('inp_value_'+sid);
                labelEl.focus();
                installBulkPaste(labelEl, cid, sid);
                installFormBlur([labelEl, valueEl], function(values){ return submitEntry(cid, sid, values); }, function(){ hideAddEntryForm(sid); });
              },50);
            }
            function hideAddEntryForm(sid) {
              var form = document.getElementById('entryForm_'+sid);
              if (form) { form.classList.remove('show'); var inputs = form.querySelectorAll('input,textarea'); inputs.forEach(function(i){i.value='';}); }
            }
            function submitEntry(cid, sid, values) {
              var l = values[0], v = values[1];
              if (!l||!v) return false;
              var s = findSectionInCard(cid, sid);
              if (s) { s.items.push({id:uid(),label:l,value:v}); save(); render(); }
              return true;
            }
            function showAddActionForm(cid, sid) {
              var form = document.getElementById('actionForm_'+sid);
              form.classList.add('show');
              setTimeout(function(){
                var labelEl = document.getElementById('act_label_'+sid);
                var cmdEl = document.getElementById('act_command_'+sid);
                labelEl.focus();
                installFormBlur([labelEl, cmdEl], function(values){ return submitAction(cid, sid, values); }, function(){ hideAddActionForm(sid); });
              },50);
            }
            function hideAddActionForm(sid) {
              var form = document.getElementById('actionForm_'+sid);
              if (form) { form.classList.remove('show'); var inputs = form.querySelectorAll('input,textarea'); inputs.forEach(function(i){i.value='';}); }
            }
            function submitAction(cid, sid, values) {
              var l = values[0];
              var c = values[1];
              if (!l||!c) return false;
              var s = findSectionInCard(cid, sid);
              if (s) { s.items.push({id:uid(),type:'action',label:l,command:c}); save(); render(); }
              return true;
            }
            function showAddLaunchForm(cid, sid) {
              var form = document.getElementById('launchForm_'+sid);
              form.classList.add('show');
              setTimeout(function(){
                var labelEl = document.getElementById('lnc_label_'+sid);
                var cmdEl = document.getElementById('lnc_command_'+sid);
                labelEl.focus();
                installFormBlur([labelEl, cmdEl], function(values){ return submitLaunch(cid, sid, values); }, function(){ hideAddLaunchForm(sid); });
              },50);
            }
            function hideAddLaunchForm(sid) {
              var form = document.getElementById('launchForm_'+sid);
              if (form) { form.classList.remove('show'); var inputs = form.querySelectorAll('input,textarea'); inputs.forEach(function(i){i.value='';}); }
            }
            function submitLaunch(cid, sid, values) {
              var l = values[0];
              var c = values[1];
              if (!l||!c) return false;
              var s = findSectionInCard(cid, sid);
              if (s) { s.items.push({id:uid(),type:'launch',label:l,command:c}); save(); render(); }
              return true;
            }
            function showNewSectionForm(cid) {
              hideContextMenu();
              document.getElementById('newSectionForm_'+cid).classList.add('show');
              setTimeout(function(){
                var el = document.getElementById('newSectionTitle_'+cid);
                el.focus();
                installFormBlur([el], function(values){ submitNewSection(cid, values); }, function(){ hideNewSectionForm(cid); });
              },50);
            }
            function hideNewSectionForm(cid) {
              var form = document.getElementById('newSectionForm_'+cid);
              if (form) { form.classList.remove('show'); var inputs = form.querySelectorAll('input'); inputs.forEach(function(i){i.value='';}); }
            }
            function submitNewSection(cid, values) {
              var t = values[0]; if (!t) return;
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
                installFormBlur([el], function(values){ submitSubsection(cid, sid, values); }, function(){ hideSubsectionForm(sid); });
              },50);
            }
            function hideSubsectionForm(sid) {
              var form = document.getElementById('newSubsectionForm_'+sid);
              if (form) { form.classList.remove('show'); var inputs = form.querySelectorAll('input'); inputs.forEach(function(i){i.value='';}); }
            }
            function submitSubsection(cid, sid, values) {
              var t = values[0]; if (!t) return;
              var s = findSectionInCard(cid, sid);
              if (s) { if (!s.sections) s.sections = []; s.sections.push({id:uid(),title:t,items:[],sections:[]}); save(); render(); }
            }

            // INLINE EDIT
            var editBlurTimeout = null;
            var formBlurTimeout = null;
            var pendingEditCommit = null;
            var pendingFormCommit = null;

            function startEditItem(cid, sid, iid) {
              hideContextMenu();
              editingItemId = iid; editingSectionId = null;
              render();
              setTimeout(function(){
                var labelEl = document.getElementById('edit_label_'+iid);
                var valueEl = document.getElementById('edit_value_'+iid);
                if(labelEl) {
                  labelEl.closest('.row-editing').scrollIntoView({ block: 'nearest' });
                  labelEl.focus();
                }
                installEditBlur([labelEl, valueEl], function(values){ trySaveEditItem(cid,sid,iid,values); });
              }, 50);
            }
            // Harvest an in-progress inline edit before an unrelated render()
            // rebuilds the DOM — otherwise the typed text is silently lost and
            // a stuck "ghost" edit row can survive across page switches.
            function commitPendingEdit() {
              commitScheduledBlur();
              if (editingItemId) {
                var row = document.querySelector('.row-editing');
                if (row) {
                  trySaveEditItem(row.dataset.editCard, row.dataset.editSection, row.dataset.editItem,
                    captureValues([row.querySelector('input'), row.querySelector('textarea')]));
                }
                else editingItemId = null;
              }
              if (editingSectionId) {
                var sec = document.querySelector('.section-title-editing');
                if (sec) trySaveEditSection(sec.dataset.editCard, sec.dataset.editSid, captureValues([sec.querySelector('input')]));
                else editingSectionId = null;
              }
            }

            function trySaveEditItem(cid, sid, iid, values) {
              var l = values[0], v = values[1];
              if (l && v) {
                var sec = findSectionInCard(cid, sid);
                if (sec) {
                  var item = sec.items.find(function(i){return i.id===iid;});
                  if (item) {
                    item.label = l;
                    if (item.type === 'action' || item.type === 'launch') item.command = v;
                    else item.value = v;
                  }
                }
                save();
              }
              if (editingItemId === iid) editingItemId = null;
              render();
            }
            function startEditSection(cid, sid) {
              hideContextMenu();
              editingSectionId = sid; editingItemId = null;
              render();
              setTimeout(function(){
                var el = document.getElementById('edit_section_'+sid);
                if(el){ el.focus(); el.select(); }
                installEditBlur([el], function(values){ trySaveEditSection(cid,sid,values); });
              }, 50);
            }
            function trySaveEditSection(cid, sid, values) {
              var t = values[0];
              if (t) { var sec = findSectionInCard(cid,sid); if(sec) sec.title=t; save(); }
              if (editingSectionId === sid) editingSectionId = null;
              render();
            }
            function cancelEdit() {
              window._escCancel = true;
              if (editBlurTimeout) clearTimeout(editBlurTimeout);
              editBlurTimeout = null;
              pendingEditCommit = null;
              editingItemId = null; editingSectionId = null; render();
            }

            // Deferred commits retain only strings, so render() can replace
            // the form without changing which values are validated or saved.
            function captureValues(elements) {
              return elements.map(function(el){
                return el && typeof el.value === 'string' ? el.value.trim() : '';
              });
            }

            function commitScheduledBlur() {
              if (pendingFormCommit) {
                var formCommit = pendingFormCommit;
                pendingFormCommit = null;
                if (formBlurTimeout) clearTimeout(formBlurTimeout);
                formBlurTimeout = null;
                if (window._escCancel) {
                  window._escCancel = false;
                  formCommit.cancelFn();
                } else if (!formCommit.values.some(function(value){ return value; })) {
                  formCommit.cancelFn();
                } else if (formCommit.saveFn(formCommit.values) === false) {
                  formCommit.cancelFn();
                  showToast('Not saved — required fields missing', 'error');
                }
              }
              if (pendingEditCommit) {
                var editCommit = pendingEditCommit;
                pendingEditCommit = null;
                if (editBlurTimeout) clearTimeout(editBlurTimeout);
                editBlurTimeout = null;
                if (window._escCancel) window._escCancel = false;
                else editCommit.saveFn(editCommit.values);
              }
            }

            function installFormBlur(elements, saveFn, cancelFn) {
              var blurGroup = {};
              elements.forEach(function(el){
                // Form elements survive show/hide cycles (only render()
                // recreates them) — guard against stacking duplicate blur
                // listeners that would double-fire the save.
                if (!el || el._blurBound) return;
                el._blurBound = true;
                el.addEventListener('blur', function(){
                  var pending = {
                    group: blurGroup,
                    values: captureValues(elements),
                    saveFn: saveFn,
                    cancelFn: cancelFn
                  };
                  pendingFormCommit = pending;
                  formBlurTimeout = setTimeout(function(){
                    if (pendingFormCommit === pending) commitScheduledBlur();
                  }, 100);
                });
                el.addEventListener('focus', function(){
                  if (pendingFormCommit && pendingFormCommit.group === blurGroup) {
                    if (formBlurTimeout) clearTimeout(formBlurTimeout);
                    formBlurTimeout = null;
                    pendingFormCommit = null;
                  }
                });
              });
            }

            function installEditBlur(elements, saveFn) {
              var blurGroup = {};
              elements.forEach(function(el){
                if (!el || el._blurBound) return;
                el._blurBound = true;
                el.addEventListener('blur', function(){
                  var pending = { group: blurGroup, values: captureValues(elements), saveFn: saveFn };
                  pendingEditCommit = pending;
                  editBlurTimeout = setTimeout(function(){
                    if (pendingEditCommit === pending) commitScheduledBlur();
                  }, 100);
                });
                el.addEventListener('focus', function(){
                  if (pendingEditCommit && pendingEditCommit.group === blurGroup) {
                    if (editBlurTimeout) clearTimeout(editBlurTimeout);
                    editBlurTimeout = null;
                    pendingEditCommit = null;
                  }
                });
              });
            }

            // Position a context menu fully on-screen (clamps both axes using
            // the menu's real rendered size)
            function placeMenu(m, x, y) {
              m.classList.add('show');
              var mw = m.offsetWidth, mh = m.offsetHeight;
              m.style.left = Math.max(4, Math.min(x, window.innerWidth - mw - 4)) + 'px';
              m.style.top = Math.max(4, Math.min(y, window.innerHeight - mh - 4)) + 'px';
            }

            // Drop recents refs that no longer resolve (after any deletion)
            function pruneRecents() {
              data.pages.forEach(function(p){
                if (p.recents) p.recents = p.recents.filter(function(r){ return resolveRecent(p, r); });
              });
            }

            // ENTRY CONTEXT MENU (right-click on a row)
            function showEntryMenu(e, cid, sid, iid) {
              e.preventDefault(); e.stopPropagation();
              var sec = findSectionInCard(cid, sid);
              var item = sec && sec.items.find(function(i){ return i.id === iid; });
              var m = document.getElementById('contextMenu');
              var html =
                '<div class="context-menu-item" onclick="startEditItem('+escHandlerArg(cid)+','+escHandlerArg(sid)+','+escHandlerArg(iid)+')">Edit</div>' +
                '<div class="context-menu-item" onclick="duplicateEntry('+escHandlerArg(cid)+','+escHandlerArg(sid)+','+escHandlerArg(iid)+')">Duplicate</div>';
              if (item && !item.type) {
                html += '<div class="context-menu-item" onclick="toggleItemHide('+escHandlerArg(cid)+','+escHandlerArg(sid)+','+escHandlerArg(iid)+')">Hide Value <div class="context-menu-toggle'+(item.hide?' on':'')+'"></div></div>';
              }
              html +=
                '<div class="context-menu-sep"></div>' +
                '<div class="context-menu-item danger" onclick="deleteOneEntry('+escHandlerArg(cid)+','+escHandlerArg(sid)+','+escHandlerArg(iid)+')">Delete</div>';
              m.innerHTML = html;
              placeMenu(m, e.clientX, e.clientY+4);
            }
            function toggleItemHide(cid, sid, iid) {
              hideContextMenu();
              var sec = findSectionInCard(cid, sid);
              var item = sec && sec.items.find(function(i){ return i.id === iid; });
              if (!item) return;
              item.hide = !item.hide;
              if (!item.hide) delete item.hide;
              save(); render();
            }
            function duplicateEntry(cid, sid, iid) {
              hideContextMenu();
              var sec = findSectionInCard(cid, sid);
              if (!sec) return;
              var idx = sec.items.findIndex(function(i){ return i.id === iid; });
              if (idx < 0) return;
              var copy = JSON.parse(JSON.stringify(sec.items[idx]));
              copy.id = uid();
              sec.items.splice(idx + 1, 0, copy);
              save(); render();
            }
            function deleteOneEntry(cid, sid, iid) {
              hideContextMenu();
              var sec = findSectionInCard(cid, sid);
              if (!sec) return;
              var item = sec.items.find(function(i){ return i.id === iid; });
              if (!item) return;
              showConfirm('Delete "'+esc(item.label)+'"?', 'This entry will be permanently deleted.', function(){
                sec.items = sec.items.filter(function(i){ return i.id !== iid; });
                pruneRecents();
                save(); render();
              });
            }

            // RECENTS CONTEXT MENUS (right-click on a recents row / the card header)
            function showRecentMenu(e, cid, sid, iid) {
              e.preventDefault(); e.stopPropagation();
              var m = document.getElementById('contextMenu');
              m.innerHTML =
                '<div class="context-menu-item" onclick="startEditItem('+escHandlerArg(cid)+','+escHandlerArg(sid)+','+escHandlerArg(iid)+')">Edit</div>' +
                '<div class="context-menu-sep"></div>' +
                '<div class="context-menu-item" onclick="removeFromRecents('+escHandlerArg(iid)+')">Remove from Recents</div>';
              placeMenu(m, e.clientX, e.clientY+4);
            }
            function removeFromRecents(iid) {
              hideContextMenu();
              var page = activePage();
              if (!page || !page.recents) return;
              page.recents = page.recents.filter(function(r){ return r.itemId !== iid; });
              save(); updateRecentsMount();
            }
            function showRecentsCardMenu(e) {
              e.preventDefault(); e.stopPropagation();
              var m = document.getElementById('contextMenu');
              m.innerHTML = '<div class="context-menu-item" onclick="clearRecents()">Clear Recently Copied</div>';
              placeMenu(m, e.clientX, e.clientY+4);
            }
            function clearRecents() {
              hideContextMenu();
              var page = activePage();
              if (!page) return;
              page.recents = [];
              save(); updateRecentsMount();
            }

            // SECTION HEADER CONTEXT MENU (right-click on section title)
            function showSectionHeaderMenu(e, cid, sid) {
              e.preventDefault(); e.stopPropagation();
              var m = document.getElementById('contextMenu');
              m.innerHTML =
                '<div class="context-menu-item" onclick="startEditSection('+escHandlerArg(cid)+','+escHandlerArg(sid)+')">Rename Section</div>' +
                '<div class="context-menu-item" onclick="showAddEntryForm('+escHandlerArg(cid)+','+escHandlerArg(sid)+');hideContextMenu()">Add Entry</div>' +
                '<div class="context-menu-item" onclick="showAddActionForm('+escHandlerArg(cid)+','+escHandlerArg(sid)+');hideContextMenu()">Add Action</div>' +
                '<div class="context-menu-item" onclick="showAddLaunchForm('+escHandlerArg(cid)+','+escHandlerArg(sid)+');hideContextMenu()">Add Launch</div>' +
                '<div class="context-menu-item" onclick="showSubsectionForm('+escHandlerArg(cid)+','+escHandlerArg(sid)+')">Add Subsection</div>' +
                '<div class="context-menu-sep"></div>' +
                '<div class="context-menu-item danger" onclick="deleteSection('+escHandlerArg(cid)+','+escHandlerArg(sid)+')">Delete Section</div>';
              placeMenu(m, e.clientX, e.clientY+4);
            }
            function countSectionContents(s) {
              var items = s.items ? s.items.length : 0, sections = 0;
              (s.sections || []).forEach(function(cs){
                var r = countSectionContents(cs);
                items += r.items; sections += 1 + r.sections;
              });
              return { items: items, sections: sections };
            }
            function removeSectionById(sections, sid) {
              for (var i = 0; i < sections.length; i++) {
                if (sections[i].id === sid) { sections.splice(i, 1); return true; }
                if (sections[i].sections && removeSectionById(sections[i].sections, sid)) return true;
              }
              return false;
            }
            function deleteSection(cid, sid) {
              hideContextMenu();
              var card = activePage().cards.find(function(c){ return c.id === cid; });
              var sec = card && findSection(card.sections, sid);
              if (!card || !sec) return;
              var counts = countSectionContents(sec);
              var body;
              if (!counts.items && !counts.sections) body = 'This section is empty.';
              else {
                body = 'This will permanently delete ' + counts.items + ' entr' + (counts.items === 1 ? 'y' : 'ies');
                if (counts.sections) body += ' and ' + counts.sections + ' subsection' + (counts.sections === 1 ? '' : 's');
                body += '.';
              }
              showConfirm('Delete "'+esc(sec.title)+'"?', body, function(){
                removeSectionById(card.sections, sid);
                pruneRecents();
                save(); render();
              });
            }

            // SECTION DROPDOWN (from the small arrow next to +)
            function showSectionDropdown(e, cid, sid) {
              e.stopPropagation();
              var m = document.getElementById('contextMenu');
              m.innerHTML =
                '<div class="context-menu-item" onclick="showAddEntryForm('+escHandlerArg(cid)+','+escHandlerArg(sid)+');hideContextMenu()">Add Entry</div>' +
                '<div class="context-menu-item" onclick="showAddActionForm('+escHandlerArg(cid)+','+escHandlerArg(sid)+');hideContextMenu()">Add Action</div>' +
                '<div class="context-menu-item" onclick="showAddLaunchForm('+escHandlerArg(cid)+','+escHandlerArg(sid)+');hideContextMenu()">Add Launch</div>' +
                '<div class="context-menu-item" onclick="showSubsectionForm('+escHandlerArg(cid)+','+escHandlerArg(sid)+')">Add Subsection</div>';
              var r = e.target.getBoundingClientRect();
              placeMenu(m, r.right - 150, r.bottom+4);
            }
            function showNewCardForm() {
              document.getElementById('newCardForm').classList.add('show');
              setTimeout(function(){
                var t = document.getElementById('newCardTitle');
                var s = document.getElementById('newCardSection');
                t.focus();
                installFormBlur([t, s], function(values){ return submitNewCard(values); }, function(){ hideNewCardForm(); });
              },50);
            }
            function hideNewCardForm() {
              var form = document.getElementById('newCardForm');
              if (form) { form.classList.remove('show'); var inputs = form.querySelectorAll('input'); inputs.forEach(function(i){i.value='';}); }
            }
            function submitNewCard(values) {
              var t = values[0], s = values[1]||'General';
              if (!t) return false;
              var page = activePage(); if (!page) return true;
              page.cards.push({id:uid(),title:t,hideValues:false,sections:[{id:uid(),title:s,items:[]}]});
              save(); render();
              return true;
            }
            function showRenameForm(cid) {
              hideContextMenu();
              document.getElementById('renameForm_'+cid).classList.add('show');
              setTimeout(function(){
                var inp = document.getElementById('renameInput_'+cid);
                inp.focus(); inp.select();
                installFormBlur([inp], function(values){ submitRename(cid, values); }, function(){ hideRenameForm(cid); });
              },50);
            }
            function hideRenameForm(cid) {
              var form = document.getElementById('renameForm_'+cid);
              if (form) form.classList.remove('show');
            }
            function submitRename(cid, values) {
              var t = values[0]; if (!t) return;
              var c = activePage().cards.find(function(x){return x.id===cid;}); if (c) c.title=t;
              save(); render();
            }
            function deleteCard(cid) {
              hideContextMenu();
              var page = activePage(); if (!page) return;
              var c = page.cards.find(function(x){return x.id===cid;}); if (!c) return;
              showConfirm('Delete "'+esc(c.title)+'"?','This will permanently delete this card and all its entries.',function(){
                page.cards=page.cards.filter(function(x){return x.id!==cid;});
                pruneRecents();
                save(); render();
              });
            }

            // ===== PAGE MANAGEMENT =====
            function switchPage(pageId) {
              commitPendingEdit();
              activePageId = pageId;
              exitSelectMode();
            }
            function addPage() {
              commitPendingEdit();
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
              // Tabs render in data.pages order — match by index, not by name,
              // so duplicate page names rename the right tab.
              var idx = data.pages.findIndex(function(p){ return p.id === pageId; });
              var tabs = document.querySelectorAll('.tab');
              if (idx >= 0 && tabs[idx]) startRenameTabEl(tabs[idx], pageId);
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
              commitPendingEdit();
              if (data.pages.length <= 1) { showToast('Cannot delete the last page', 'error'); return; }
              var page = data.pages.find(function(p){ return p.id === pageId; });
              showConfirm('Delete page "'+esc(page.name)+'"?','This will delete all cards in this page.',function(){
                data.pages = data.pages.filter(function(p){ return p.id !== pageId; });
                if (activePageId === pageId) activePageId = data.pages[0].id;
                save(); render();
              });
            }
            function toggleHideValues(cid) {
              commitPendingEdit();
              var c = activePage().cards.find(function(x){return x.id===cid;}); if (c) c.hideValues=!c.hideValues;
              save(); render(); hideContextMenu();
            }

            // ===== CONTEXT MENU =====
            function showCardMenu(e, cid) {
              e.stopPropagation();
              var c = activePage().cards.find(function(x){return x.id===cid;});
              var m = document.getElementById('contextMenu');
              m.innerHTML =
                '<div class="context-menu-item" onclick="toggleHideValues('+escHandlerArg(cid)+')">Hide Values <div class="context-menu-toggle'+(c&&c.hideValues?' on':'')+'"></div></div>' +
                '<div class="context-menu-sep"></div>' +
                '<div class="context-menu-item" onclick="showNewSectionForm('+escHandlerArg(cid)+')">Add Section</div>' +
                '<div class="context-menu-item" onclick="showRenameForm('+escHandlerArg(cid)+')">Rename Card</div>' +
                '<div class="context-menu-item" onclick="enterSelectMode('+escHandlerArg(cid)+')">Select &amp; Delete Items</div>' +
                '<div class="context-menu-sep"></div>' +
                '<div class="context-menu-item danger" onclick="deleteCard('+escHandlerArg(cid)+')">Delete Card</div>';
              var r = e.target.getBoundingClientRect();
              placeMenu(m, r.left, r.bottom+4);
            }
            function showTabContextMenu(e, pageId) {
              e.preventDefault(); e.stopPropagation();
              var page = data.pages.find(function(p){ return p.id === pageId; });
              if (!page) return;
              var m = document.getElementById('contextMenu');
              var html = '<div class="context-menu-item" onclick="startRenameTabById('+escHandlerArg(pageId)+');hideContextMenu()">Rename</div>';
              if (data.pages.length > 1) {
                html += '<div class="context-menu-sep"></div>';
                html += '<div class="context-menu-item danger" onclick="deletePage('+escHandlerArg(pageId)+');hideContextMenu()">Delete</div>';
              }
              m.innerHTML = html;
              var r = e.target.getBoundingClientRect();
              placeMenu(m, r.left, r.bottom+4);
            }
            function hideContextMenu() { document.getElementById('contextMenu').classList.remove('show'); }

            // Escape priority stack: menu > dialog > tab rename > search field >
            // inline edit > form input > select mode > active search filter.
            // Returns true when the press was consumed inside the widget; the
            // Swift panel only dismisses itself when this returns false.
            window._handleEscape = function() {
              var menu = document.getElementById('contextMenu');
              if (menu && menu.classList.contains('show')) { hideContextMenu(); return true; }
              var overlay = document.getElementById('confirmOverlay');
              if (overlay && overlay.classList.contains('show')) { hideConfirm(); return true; }
              var ae = document.activeElement;
              if (ae && ae.classList && ae.classList.contains('tab-rename-input')) { render(); return true; }
              if (ae && ae.id === 'searchInput') { clearSearch(); ae.blur(); return true; }
              if (editingItemId || editingSectionId) {
                cancelEdit();
                // cancelEdit re-renders, which destroys the inputs without a
                // blur event — reset the flag so it can't cancel (and silently
                // discard) the next form save.
                window._escCancel = false;
                return true;
              }
              if (ae && (ae.tagName === 'INPUT' || ae.tagName === 'TEXTAREA')) {
                // An add/rename form input: cancel it without saving
                window._escCancel = true;
                ae.blur();
                return true;
              }
              if (selectMode) { exitSelectMode(); return true; }
              if (searchQuery.trim()) { clearSearch(); return true; }
              return false;
            };

            document.addEventListener('click', function(e) { if (!e.target.closest('.context-menu') && !e.target.closest('.card-menu-btn')) hideContextMenu(); });
            document.addEventListener('keydown', function(e) {
              // Enter in inline edit → save
              if (e.key==='Enter' && (editingItemId || editingSectionId)) {
                if (e.target.tagName==='TEXTAREA' && e.shiftKey) return; // allow shift+enter in textarea
                e.preventDefault();
                commitPendingEdit();
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
              if (e.key==='Escape') { if (window._handleEscape()) e.preventDefault(); }
              if ((e.metaKey || e.ctrlKey) && e.key === 'f') { e.preventDefault(); window._focusSearch(); }
            });

            // Search field lives outside #app so re-renders never steal its focus
            (function initSearch() {
              var input = document.getElementById('searchInput');
              var clearBtn = document.getElementById('searchClear');
              var app = document.getElementById('app');
              if (!input) return;
              input.addEventListener('input', function(){
                commitPendingEdit();
                searchQuery = input.value;
                activeSearchItemId = null;
                // Filtering can hide the card being bulk-edited while its
                // select-bar stays live — leave select mode instead.
                if (selectMode && searchQuery.trim()) { selectMode = false; selectCardId = null; selected = {}; }
                document.getElementById('searchWrap').classList.toggle('has-query', !!searchQuery.trim());
                render();
              });
              input.addEventListener('keydown', function(ev){
                if (ev.key === 'ArrowDown' || ev.key === 'ArrowUp') {
                  if (!searchQ()) return;
                  ev.preventDefault();
                  moveActiveSearchRow(ev.key === 'ArrowDown' ? 1 : -1);
                  return;
                }
                if (ev.key === 'Enter') {
                  ev.preventDefault();
                  if (selectMode) return;  // rows are selection toggles here
                  activateActiveSearchRow();
                }
              });
              app.addEventListener('mouseover', function(ev) {
                if (!searchQ()) return;
                var row = ev.target.closest('.row[data-item]');
                if (row && app.contains(row)) setActiveSearchRow(row.dataset.item, false);
              });
              clearBtn.addEventListener('click', function(){ clearSearch(); });
            })();

            if (data.pages.length) activePageId = data.pages[0].id;
            render();
            // Persist boot-time migrations — but ONLY when real data actually
            // loaded. If data.json exists but failed to parse/inject, saving
            // here would overwrite the user's file with the sample data.
            setTimeout(function(){ if (window._dataLoaded) save(); }, 500);
          </script>
        </body>
        </html>
        """##
}
