enum DefaultWidget {
    static let html = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          * { box-sizing: border-box; margin: 0; padding: 0; }

          body {
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif;
            background: transparent;
            color: #e0e0e0;
            padding: 48px 12px 12px 12px;
            -webkit-user-select: none;
            user-select: none;
          }

          .card {
            background: rgba(20, 20, 20, 0.85);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border-radius: 14px;
            border: 1px solid rgba(255,255,255,0.08);
            padding: 14px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.4);
            margin-bottom: 10px;
          }

          .card-header {
            display: flex; align-items: center;
            margin-bottom: 10px;
          }

          .card-title {
            font-size: 13px; font-weight: 600;
            color: rgba(255,255,255,0.9);
            flex: 1; letter-spacing: 0.02em;
          }

          .card-menu-btn {
            width: 24px; height: 24px;
            border: none; background: none;
            color: rgba(255,255,255,0.3);
            font-size: 16px; cursor: pointer;
            border-radius: 6px;
            display: flex; align-items: center; justify-content: center;
            transition: all 0.15s;
          }
          .card-menu-btn:hover { background: rgba(255,255,255,0.1); color: rgba(255,255,255,0.7); }

          .section { margin-bottom: 8px; }
          .section:last-child { margin-bottom: 0; }

          .section-header {
            display: flex; align-items: center;
            padding-bottom: 4px;
            border-bottom: 1px solid rgba(255,255,255,0.05);
            margin-bottom: 3px;
          }

          .section-title {
            font-size: 9px; font-weight: 600;
            letter-spacing: 0.08em; text-transform: uppercase;
            color: rgba(255,255,255,0.25); flex: 1;
          }

          .section-add-btn {
            width: 18px; height: 18px;
            border: none; background: none;
            color: rgba(255,255,255,0.15);
            font-size: 15px; cursor: pointer;
            border-radius: 4px; line-height: 1;
            display: flex; align-items: center; justify-content: center;
            transition: all 0.15s;
          }
          .section-add-btn:hover { background: rgba(255,255,255,0.1); color: rgba(255,255,255,0.6); }
          .card:hover .section-add-btn { color: rgba(255,255,255,0.3); }

          .row {
            position: relative;
            display: flex; align-items: center;
            padding: 5px 8px; border-radius: 6px;
            cursor: pointer; transition: background 0.15s;
          }
          .row:hover { background: rgba(255,255,255,0.07); }
          .row:active { background: rgba(255,255,255,0.12); }

          .label { color: rgba(255,255,255,0.7); font-size: 12px; flex: 1; }

          .value {
            font-size: 11px;
            font-family: 'SF Mono', Menlo, monospace;
            color: rgba(255,255,255,0.5);
            transition: all 0.25s ease;
          }
          .row:hover .value { color: rgba(255,255,255,0.9); }
          .value.copied {
            color: #34c759 !important;
            font-family: -apple-system, sans-serif;
            font-weight: 500;
          }

          /* Hidden values mode */
          .value-dots {
            font-size: 11px;
            color: rgba(255,255,255,0.2);
            letter-spacing: 2px;
          }
          .value-real { display: none; }
          .row:hover .value-dots { display: none; }
          .row:hover .value-real { display: inline; }

          /* Select mode */
          .select-checkbox {
            width: 16px; height: 16px; margin-right: 8px;
            border-radius: 4px;
            border: 1.5px solid rgba(255,255,255,0.25);
            background: none; cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0; transition: all 0.15s;
            font-size: 10px; color: transparent;
          }
          .select-checkbox:hover { border-color: rgba(255,255,255,0.5); }
          .select-checkbox.checked {
            background: #0a84ff; border-color: #0a84ff; color: white;
          }

          .section-select-checkbox {
            width: 14px; height: 14px; margin-right: 6px;
            border-radius: 3px;
            border: 1.5px solid rgba(255,255,255,0.2);
            background: none; cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0; transition: all 0.15s;
            font-size: 8px; color: transparent;
          }
          .section-select-checkbox:hover { border-color: rgba(255,255,255,0.4); }
          .section-select-checkbox.checked {
            background: #0a84ff; border-color: #0a84ff; color: white;
          }

          /* Select mode bar */
          .select-bar {
            position: fixed; bottom: 0; left: 0; right: 0;
            background: rgba(20,20,20,0.95);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border-top: 1px solid rgba(255,255,255,0.1);
            padding: 10px 16px;
            display: flex; align-items: center; gap: 8px;
            z-index: 900;
          }
          .select-bar-text {
            flex: 1; font-size: 12px;
            color: rgba(255,255,255,0.6);
          }
          .select-bar-count {
            color: #0a84ff; font-weight: 600;
          }

          .btn {
            padding: 5px 12px; border: none;
            border-radius: 6px; font-size: 11px;
            cursor: pointer; font-weight: 500; font-family: inherit;
            transition: all 0.15s;
          }
          .btn-primary { background: #0a84ff; color: white; }
          .btn-primary:hover { background: #0070e0; }
          .btn-secondary { background: rgba(255,255,255,0.1); color: rgba(255,255,255,0.7); }
          .btn-secondary:hover { background: rgba(255,255,255,0.15); }
          .btn-danger { background: #ff3b30; color: white; }
          .btn-danger:hover { background: #e0352b; }

          /* Inline forms */
          .inline-form {
            display: none;
            padding: 6px 8px;
            background: rgba(255,255,255,0.05);
            border-radius: 6px; margin-top: 4px;
          }
          .inline-form.show { display: flex; gap: 6px; align-items: center; flex-wrap: wrap; }
          .inline-form input, .card-form input {
            flex: 1; min-width: 60px;
            background: rgba(255,255,255,0.1);
            border: 1px solid rgba(255,255,255,0.15);
            border-radius: 6px; padding: 6px 10px;
            font-size: 12px; color: white;
            outline: none; font-family: inherit;
            -webkit-user-select: text; user-select: text;
          }
          .inline-form input:focus, .card-form input:focus {
            border-color: #0a84ff; background: rgba(255,255,255,0.12);
          }
          .inline-form input::placeholder, .card-form input::placeholder {
            color: rgba(255,255,255,0.3);
          }

          .add-card-btn {
            width: 100%; padding: 12px;
            border: 2px dashed rgba(255,255,255,0.15);
            background: rgba(20, 20, 20, 0.4);
            color: rgba(255,255,255,0.4);
            border-radius: 14px; cursor: pointer;
            font-size: 13px; font-family: inherit; font-weight: 500;
            transition: all 0.15s;
            display: flex; align-items: center; justify-content: center; gap: 6px;
          }
          .add-card-btn:hover {
            border-color: rgba(255,255,255,0.3);
            color: rgba(255,255,255,0.7);
            background: rgba(20, 20, 20, 0.6);
          }

          .card-form {
            display: none;
            background: rgba(20, 20, 20, 0.85);
            backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
            border-radius: 14px;
            border: 1px solid rgba(255,255,255,0.08);
            padding: 14px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.4);
            margin-bottom: 10px;
          }
          .card-form.show { display: block; }
          .card-form-title { font-size: 12px; font-weight: 600; color: rgba(255,255,255,0.6); margin-bottom: 10px; }
          .card-form .form-row { display: flex; gap: 6px; margin-bottom: 8px; }
          .card-form .form-actions { display: flex; gap: 6px; justify-content: flex-end; }

          /* Confirm dialog */
          .confirm-overlay {
            position: fixed; top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.5);
            display: none; z-index: 1100;
            align-items: center; justify-content: center;
          }
          .confirm-overlay.show { display: flex; }
          .confirm-box {
            background: rgba(40,40,40,0.98);
            border: 1px solid rgba(255,255,255,0.15);
            border-radius: 14px; padding: 18px;
            max-width: 300px; width: 90%;
            box-shadow: 0 12px 40px rgba(0,0,0,0.6);
          }
          .confirm-title { font-size: 14px; font-weight: 600; color: white; margin-bottom: 8px; }
          .confirm-body { font-size: 12px; color: rgba(255,255,255,0.6); margin-bottom: 14px; line-height: 1.5; }
          .confirm-body .item-label {
            display: block; padding: 3px 0;
            color: rgba(255,255,255,0.8);
            border-bottom: 1px solid rgba(255,255,255,0.05);
          }
          .confirm-actions { display: flex; gap: 8px; justify-content: flex-end; }

          .context-menu {
            position: fixed;
            background: rgba(30,30,30,0.98);
            border: 1px solid rgba(255,255,255,0.15);
            border-radius: 8px; padding: 4px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.5);
            z-index: 1000; min-width: 170px;
            display: none;
          }
          .context-menu.show { display: block; }
          .context-menu-item {
            padding: 6px 12px; border-radius: 4px;
            font-size: 12px; cursor: pointer;
            color: rgba(255,255,255,0.8);
            display: flex; align-items: center; gap: 6px;
          }
          .context-menu-item:hover { background: rgba(255,255,255,0.1); }
          .context-menu-item.danger { color: #ff6961; }
          .context-menu-item.danger:hover { background: rgba(255,59,48,0.15); }
          .context-menu-sep { height: 1px; background: rgba(255,255,255,0.08); margin: 3px 8px; }
          .context-menu-toggle {
            margin-left: auto;
            width: 32px; height: 18px;
            border-radius: 10px;
            background: rgba(255,255,255,0.15);
            position: relative; transition: background 0.2s;
          }
          .context-menu-toggle.on { background: #34c759; }
          .context-menu-toggle::after {
            content: ''; position: absolute;
            width: 14px; height: 14px; border-radius: 50%;
            background: white; top: 2px; left: 2px;
            transition: transform 0.2s;
          }
          .context-menu-toggle.on::after { transform: translateX(14px); }

          .toast {
            position: fixed; bottom: 20px; left: 50%;
            transform: translateX(-50%) translateY(20px);
            background: rgba(52, 199, 89, 0.95);
            color: white; padding: 6px 16px; border-radius: 20px;
            font-size: 12px; font-weight: 500;
            opacity: 0; transition: all 0.3s ease;
            pointer-events: none; z-index: 1200;
          }
          .toast.show { opacity: 1; transform: translateX(-50%) translateY(0); }
        </style>
        </head>
        <body>
          <div id="app"></div>
          <div class="context-menu" id="contextMenu"></div>
          <div class="confirm-overlay" id="confirmOverlay"><div class="confirm-box" id="confirmBox"></div></div>
          <div class="toast" id="toast"></div>

          <script>
            var DEFAULT_DATA = {
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
            };

            var data = JSON.parse(JSON.stringify(DEFAULT_DATA));
            var selectMode = false;
            var selectCardId = null;
            var selected = {};  // { itemId: true, sectionId: true }

            function uid() { return 'id_' + Date.now() + '_' + Math.random().toString(36).slice(2,7); }
            function save() { if (window.GlanceBar) GlanceBar.saveData(data); }
            window._onDataLoaded = function(saved) { if (saved && saved.cards) { data = saved; render(); } };

            function esc(s) { var d = document.createElement('div'); d.textContent = s; return d.innerHTML; }

            function render() {
              var app = document.getElementById('app');
              var html = data.cards.map(function(card) { return renderCard(card); }).join('');
              html += '<div class="card-form" id="newCardForm">' +
                '<div class="card-form-title">New Card</div>' +
                '<div class="form-row"><input id="newCardTitle" placeholder="Card name (e.g. Passwords)"></div>' +
                '<div class="form-row"><input id="newCardSection" placeholder="First section name (e.g. Email)"></div>' +
                '<div class="form-actions">' +
                  '<button class="btn btn-secondary" onclick="hideNewCardForm()">Cancel</button>' +
                  '<button class="btn btn-primary" onclick="submitNewCard()">Create</button>' +
                '</div></div>';
              html += '<button class="add-card-btn" onclick="showNewCardForm()">+ Add Card</button>';
              if (selectMode) {
                var count = Object.keys(selected).length;
                html += '<div class="select-bar">' +
                  '<span class="select-bar-text"><span class="select-bar-count">' + count + '</span> selected</span>' +
                  '<button class="btn btn-secondary" onclick="exitSelectMode()">Cancel</button>' +
                  '<button class="btn btn-danger" onclick="confirmDeleteSelected()" ' + (count === 0 ? 'style="opacity:0.4;pointer-events:none"' : '') + '>Delete</button>' +
                '</div>';
              }
              app.innerHTML = html;
            }

            function renderCard(card) {
              var isSelectingThis = selectMode && selectCardId === card.id;
              return '<div class="card" data-card="' + card.id + '">' +
                '<div class="card-header">' +
                  '<div class="card-title">' + esc(card.title) + '</div>' +
                  '<button class="card-menu-btn" onclick="showCardMenu(event,\\'' + card.id + '\\')">\\u2026</button>' +
                '</div>' +
                card.sections.map(function(s) { return renderSection(card.id, s, card.hideValues, isSelectingThis); }).join('') +
                '<div class="card-form" id="newSectionForm_' + card.id + '">' +
                  '<div class="card-form-title">New Section</div>' +
                  '<div class="form-row"><input id="newSectionTitle_' + card.id + '" placeholder="Section name"></div>' +
                  '<div class="form-actions">' +
                    '<button class="btn btn-secondary" onclick="hideNewSectionForm(\\'' + card.id + '\\')">Cancel</button>' +
                    '<button class="btn btn-primary" onclick="submitNewSection(\\'' + card.id + '\\')">Add</button>' +
                  '</div></div>' +
                '<div class="card-form" id="renameForm_' + card.id + '">' +
                  '<div class="card-form-title">Rename Card</div>' +
                  '<div class="form-row"><input id="renameInput_' + card.id + '" placeholder="New name" value="' + esc(card.title) + '"></div>' +
                  '<div class="form-actions">' +
                    '<button class="btn btn-secondary" onclick="hideRenameForm(\\'' + card.id + '\\')">Cancel</button>' +
                    '<button class="btn btn-primary" onclick="submitRename(\\'' + card.id + '\\')">Save</button>' +
                  '</div></div>' +
              '</div>';
            }

            function renderSection(cardId, section, hideValues, isSelecting) {
              var secChecked = isSelecting && selected['sec_' + section.id];
              return '<div class="section" data-section="' + section.id + '">' +
                '<div class="section-header">' +
                  (isSelecting ? '<div class="section-select-checkbox' + (secChecked ? ' checked' : '') + '" onclick="toggleSelectSection(\\'' + section.id + '\\')">' + (secChecked ? '\\u2713' : '') + '</div>' : '') +
                  '<div class="section-title">' + esc(section.title) + '</div>' +
                  (isSelecting ? '' : '<button class="section-add-btn" onclick="showAddEntryForm(\\'' + cardId + '\\',\\'' + section.id + '\\')">+</button>') +
                '</div>' +
                section.items.map(function(item) { return renderRow(cardId, section.id, item, hideValues, isSelecting); }).join('') +
                '<div class="inline-form" id="entryForm_' + section.id + '">' +
                  '<input id="inp_label_' + section.id + '" placeholder="Label">' +
                  '<input id="inp_value_' + section.id + '" placeholder="Value">' +
                  '<button class="btn btn-primary" onclick="submitEntry(\\'' + cardId + '\\',\\'' + section.id + '\\')">Add</button>' +
                  '<button class="btn btn-secondary" onclick="hideAddEntryForm(\\'' + section.id + '\\')">Cancel</button>' +
                '</div></div>';
            }

            function renderRow(cardId, sectionId, item, hideValues, isSelecting) {
              var safeVal = item.value.replace(/'/g, "\\\\'");
              var isChecked = isSelecting && selected[item.id];
              var valHtml;
              if (hideValues) {
                valHtml = '<span class="value-dots">\\u2022\\u2022\\u2022\\u2022\\u2022\\u2022</span>' +
                          '<span class="value value-real">' + esc(item.value) + '</span>';
              } else {
                valHtml = '<span class="value">' + esc(item.value) + '</span>';
              }
              if (isSelecting) {
                return '<div class="row" onclick="toggleSelectItem(\\'' + item.id + '\\')">' +
                  '<div class="select-checkbox' + (isChecked ? ' checked' : '') + '">' + (isChecked ? '\\u2713' : '') + '</div>' +
                  '<span class="label">' + esc(item.label) + '</span>' +
                  valHtml + '</div>';
              }
              return '<div class="row" onclick="copyValue(this,\\'' + safeVal + '\\','+hideValues+')" data-val="' + esc(item.value) + '">' +
                '<span class="label">' + esc(item.label) + '</span>' +
                valHtml + '</div>';
            }

            // COPY
            function copyValue(row, text, isHidden) {
              if (selectMode) return;
              if (window.GlanceBar) GlanceBar.copy(text);
              else navigator.clipboard.writeText(text).catch(function(){});
              // Save original HTML of the value area
              var dotsEl = row.querySelector('.value-dots');
              var realEl = row.querySelector('.value-real');
              var plainEl = (!dotsEl) ? row.querySelector('.value') : null;
              // Show "Copied" feedback
              if (dotsEl) dotsEl.style.display = 'none';
              if (realEl) { realEl.style.display = 'inline'; realEl.textContent = 'Copied'; realEl.classList.add('copied'); }
              if (plainEl) { var orig = plainEl.textContent; plainEl.textContent = 'Copied'; plainEl.classList.add('copied');
                setTimeout(function() { plainEl.textContent = orig; plainEl.classList.remove('copied'); }, 1200); return;
              }
              setTimeout(function() {
                if (dotsEl) dotsEl.style.display = '';
                if (realEl) { realEl.style.display = ''; realEl.textContent = text; realEl.classList.remove('copied'); }
              }, 1200);
            }

            // SELECT MODE
            function enterSelectMode(cardId) {
              selectMode = true; selectCardId = cardId; selected = {};
              hideContextMenu(); render();
            }
            function exitSelectMode() {
              selectMode = false; selectCardId = null; selected = {};
              render();
            }
            function toggleSelectItem(itemId) {
              if (selected[itemId]) delete selected[itemId];
              else selected[itemId] = true;
              render();
            }
            function toggleSelectSection(sectionId) {
              var key = 'sec_' + sectionId;
              var card = data.cards.find(function(c) { return c.id === selectCardId; });
              var section = card && card.sections.find(function(s) { return s.id === sectionId; });
              if (!section) return;
              if (selected[key]) {
                delete selected[key];
                section.items.forEach(function(i) { delete selected[i.id]; });
              } else {
                selected[key] = true;
                section.items.forEach(function(i) { selected[i.id] = true; });
              }
              render();
            }

            function confirmDeleteSelected() {
              var card = data.cards.find(function(c) { return c.id === selectCardId; });
              if (!card) return;
              var labels = [];
              var sectionLabels = [];
              card.sections.forEach(function(s) {
                if (selected['sec_' + s.id]) {
                  sectionLabels.push(s.title + ' (entire section)');
                } else {
                  s.items.forEach(function(i) {
                    if (selected[i.id]) labels.push(i.label);
                  });
                }
              });
              var all = sectionLabels.concat(labels);
              if (all.length === 0) return;
              showConfirm(
                'Delete ' + all.length + ' item' + (all.length > 1 ? 's' : '') + '?',
                all.map(function(l) { return '<span class="item-label">' + esc(l) + '</span>'; }).join(''),
                function() {
                  card.sections.forEach(function(s) {
                    if (selected['sec_' + s.id]) { s.items = []; s._delete = true; }
                    else { s.items = s.items.filter(function(i) { return !selected[i.id]; }); }
                  });
                  card.sections = card.sections.filter(function(s) { return !s._delete; });
                  save(); exitSelectMode();
                }
              );
            }

            // CONFIRM DIALOG
            function showConfirm(title, bodyHtml, onConfirm) {
              var box = document.getElementById('confirmBox');
              box.innerHTML = '<div class="confirm-title">' + title + '</div>' +
                '<div class="confirm-body">' + bodyHtml + '</div>' +
                '<div class="confirm-actions">' +
                  '<button class="btn btn-secondary" id="confirmCancel">Cancel</button>' +
                  '<button class="btn btn-danger" id="confirmOk">Delete</button>' +
                '</div>';
              document.getElementById('confirmOverlay').classList.add('show');
              document.getElementById('confirmCancel').onclick = hideConfirm;
              document.getElementById('confirmOk').onclick = function() { hideConfirm(); onConfirm(); };
            }
            function hideConfirm() {
              document.getElementById('confirmOverlay').classList.remove('show');
            }

            // ADD ENTRY
            function showAddEntryForm(cardId, sectionId) {
              var form = document.getElementById('entryForm_' + sectionId);
              form.classList.add('show');
              setTimeout(function() { document.getElementById('inp_label_' + sectionId).focus(); }, 50);
            }
            function hideAddEntryForm(sectionId) { document.getElementById('entryForm_' + sectionId).classList.remove('show'); }
            function submitEntry(cardId, sectionId) {
              var label = document.getElementById('inp_label_' + sectionId).value.trim();
              var value = document.getElementById('inp_value_' + sectionId).value.trim();
              if (!label || !value) return;
              var card = data.cards.find(function(c) { return c.id === cardId; });
              var section = card && card.sections.find(function(s) { return s.id === sectionId; });
              if (!section) return;
              section.items.push({ id: uid(), label: label, value: value });
              save(); render();
            }

            // ADD SECTION
            function showNewSectionForm(cardId) {
              hideContextMenu();
              document.getElementById('newSectionForm_' + cardId).classList.add('show');
              setTimeout(function() { document.getElementById('newSectionTitle_' + cardId).focus(); }, 50);
            }
            function hideNewSectionForm(cardId) { document.getElementById('newSectionForm_' + cardId).classList.remove('show'); }
            function submitNewSection(cardId) {
              var title = document.getElementById('newSectionTitle_' + cardId).value.trim();
              if (!title) return;
              var card = data.cards.find(function(c) { return c.id === cardId; });
              if (!card) return;
              card.sections.push({ id: uid(), title: title, items: [] });
              save(); render();
            }

            // ADD CARD
            function showNewCardForm() {
              document.getElementById('newCardForm').classList.add('show');
              setTimeout(function() { document.getElementById('newCardTitle').focus(); }, 50);
            }
            function hideNewCardForm() { document.getElementById('newCardForm').classList.remove('show'); }
            function submitNewCard() {
              var title = document.getElementById('newCardTitle').value.trim();
              var sec = document.getElementById('newCardSection').value.trim() || 'General';
              if (!title) return;
              data.cards.push({ id: uid(), title: title, hideValues: false, sections: [{ id: uid(), title: sec, items: [] }] });
              save(); render();
            }

            // RENAME
            function showRenameForm(cardId) {
              hideContextMenu();
              document.getElementById('renameForm_' + cardId).classList.add('show');
              setTimeout(function() { var inp = document.getElementById('renameInput_' + cardId); inp.focus(); inp.select(); }, 50);
            }
            function hideRenameForm(cardId) { document.getElementById('renameForm_' + cardId).classList.remove('show'); }
            function submitRename(cardId) {
              var title = document.getElementById('renameInput_' + cardId).value.trim();
              if (!title) return;
              var card = data.cards.find(function(c) { return c.id === cardId; });
              if (card) card.title = title;
              save(); render();
            }

            // DELETE CARD
            function deleteCard(cardId) {
              hideContextMenu();
              var card = data.cards.find(function(c) { return c.id === cardId; });
              if (!card) return;
              showConfirm(
                'Delete "' + esc(card.title) + '"?',
                'This will permanently delete this card and all its entries.',
                function() {
                  data.cards = data.cards.filter(function(c) { return c.id !== cardId; });
                  save(); render();
                }
              );
            }

            // TOGGLE HIDE VALUES
            function toggleHideValues(cardId) {
              var card = data.cards.find(function(c) { return c.id === cardId; });
              if (!card) return;
              card.hideValues = !card.hideValues;
              save(); render(); hideContextMenu();
            }

            // CONTEXT MENU
            function showCardMenu(e, cardId) {
              e.stopPropagation();
              var card = data.cards.find(function(c) { return c.id === cardId; });
              var menu = document.getElementById('contextMenu');
              var hideOn = card && card.hideValues;
              menu.innerHTML =
                '<div class="context-menu-item" onclick="toggleHideValues(\\'' + cardId + '\\')">' +
                  'Hide Values <div class="context-menu-toggle' + (hideOn ? ' on' : '') + '"></div></div>' +
                '<div class="context-menu-sep"></div>' +
                '<div class="context-menu-item" onclick="showNewSectionForm(\\'' + cardId + '\\')">Add Section</div>' +
                '<div class="context-menu-item" onclick="showRenameForm(\\'' + cardId + '\\')">Rename Card</div>' +
                '<div class="context-menu-item" onclick="enterSelectMode(\\'' + cardId + '\\')">Select &amp; Delete Items</div>' +
                '<div class="context-menu-sep"></div>' +
                '<div class="context-menu-item danger" onclick="deleteCard(\\'' + cardId + '\\')">Delete Card</div>';
              var rect = e.target.getBoundingClientRect();
              menu.style.left = Math.min(rect.left, window.innerWidth - 190) + 'px';
              menu.style.top = (rect.bottom + 4) + 'px';
              menu.classList.add('show');
            }
            function hideContextMenu() { document.getElementById('contextMenu').classList.remove('show'); }

            document.addEventListener('click', function(e) {
              if (!e.target.closest('.context-menu') && !e.target.closest('.card-menu-btn')) hideContextMenu();
            });
            document.addEventListener('keydown', function(e) {
              if (e.key === 'Enter' && e.target.tagName === 'INPUT') {
                var form = e.target.closest('.inline-form, .card-form');
                if (form) { var btn = form.querySelector('.btn-primary'); if (btn) btn.click(); }
              }
              if (e.key === 'Escape') {
                if (selectMode) { exitSelectMode(); return; }
                hideConfirm();
              }
            });

            render();
            setTimeout(function() { save(); }, 500);
          </script>
        </body>
        </html>
        """
}
