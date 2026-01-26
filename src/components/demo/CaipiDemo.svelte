<script lang="ts">
  import {
    PanelLeft,
    PanelRight,
    Sun,
    Moon,
    Home,
    ChevronRight,
    ChevronDown,
    File,
    Folder,
    FolderOpen,
    Eye,
    Pencil,
    Terminal,
    Check,
    Loader2,
    ArrowUp,
    Shield,
    Circle,
    Sparkles,
  } from 'lucide-svelte';

  // Demo state
  let leftSidebarOpen = $state(true);
  let rightSidebarOpen = $state(true);
  let darkMode = $state(true);
  let inputValue = $state('');
  let expandedFolders = $state<Set<string>>(new Set(['src', 'src/lib']));

  // Toggle dark mode and sync with document
  function toggleDarkMode() {
    darkMode = !darkMode;
    if (typeof document !== 'undefined') {
      document.documentElement.classList.toggle('dark', darkMode);
      localStorage.setItem('theme', darkMode ? 'dark' : 'light');
    }
  }

  // Demo file tree
  const fileTree = [
    { name: 'src', type: 'folder', children: [
      { name: 'lib', type: 'folder', children: [
        { name: 'components', type: 'folder', children: [
          { name: 'Button.svelte', type: 'file' },
          { name: 'Card.svelte', type: 'file' },
        ]},
        { name: 'utils.ts', type: 'file' },
      ]},
      { name: 'app.css', type: 'file' },
      { name: 'main.ts', type: 'file' },
    ]},
    { name: 'package.json', type: 'file' },
    { name: 'README.md', type: 'file' },
  ];

  // Demo messages
  const messages = [
    {
      role: 'user',
      content: 'Can you help me refactor the Button component to use Svelte 5 runes?'
    },
    {
      role: 'assistant',
      content: "I'll update the Button component to use Svelte 5's new runes syntax. Let me read the current implementation first.",
      tools: [
        { type: 'Read', target: 'src/lib/components/Button.svelte', status: 'completed' },
      ]
    },
    {
      role: 'assistant',
      content: "Now I'll refactor it to use `$props()` and `$state()` runes for better reactivity.",
      tools: [
        { type: 'Edit', target: 'src/lib/components/Button.svelte', status: 'completed' },
        { type: 'Bash', target: 'npm run check', status: 'running' },
      ]
    },
  ];

  // Demo todos
  const todos = [
    { status: 'done', text: 'Read current implementation' },
    { status: 'active', text: 'Refactor to use runes' },
    { status: 'pending', text: 'Run type checks' },
    { status: 'pending', text: 'Update tests' },
  ];

  // Demo skills
  const skills = [
    { name: 'Svelte 5 Guide' },
    { name: 'TypeScript Patterns' },
  ];

  function toggleFolder(path: string) {
    if (expandedFolders.has(path)) {
      expandedFolders.delete(path);
    } else {
      expandedFolders.add(path);
    }
    expandedFolders = new Set(expandedFolders);
  }

  function getToolIcon(type: string) {
    switch (type) {
      case 'Read': return Eye;
      case 'Edit': return Pencil;
      case 'Bash': return Terminal;
      default: return Terminal;
    }
  }

  function getToolColor(type: string) {
    switch (type) {
      case 'Read': return 'text-blue-500 bg-blue-500/10 border-blue-500/20';
      case 'Edit': return 'text-amber-500 bg-amber-500/10 border-amber-500/20';
      case 'Bash': return 'text-purple-500 bg-purple-500/10 border-purple-500/20';
      default: return 'text-purple-500 bg-purple-500/10 border-purple-500/20';
    }
  }

  interface FileNode {
    name: string;
    type: 'file' | 'folder';
    children?: FileNode[];
  }

  function renderFileTree(nodes: FileNode[], parentPath = ''): { node: FileNode; path: string; depth: number }[] {
    const items: { node: FileNode; path: string; depth: number }[] = [];
    for (const node of nodes) {
      const path = parentPath ? `${parentPath}/${node.name}` : node.name;
      const depth = path.split('/').length - 1;
      items.push({ node, path, depth });
      if (node.type === 'folder' && node.children && expandedFolders.has(path)) {
        items.push(...renderFileTree(node.children, path));
      }
    }
    return items;
  }

  const flatFileTree = $derived(renderFileTree(fileTree));
</script>

<div class="demo-window rounded-xl overflow-hidden bg-background border border-border">
  <!-- Window chrome -->
  <div class="h-9 bg-sidebar border-b border-border flex items-center px-3 gap-2">
    <div class="flex gap-1.5">
      <div class="w-3 h-3 rounded-full bg-red-500/80"></div>
      <div class="w-3 h-3 rounded-full bg-yellow-500/80"></div>
      <div class="w-3 h-3 rounded-full bg-green-500/80"></div>
    </div>

    <!-- Header controls -->
    <div class="flex-1 flex items-center justify-between ml-4">
      <div class="flex items-center gap-1">
        <button
          class="p-1.5 rounded-md hover:bg-muted transition-colors"
          onclick={() => leftSidebarOpen = !leftSidebarOpen}
        >
          <PanelLeft size={14} class="text-muted-foreground" />
        </button>
        <button class="p-1.5 rounded-md hover:bg-muted transition-colors">
          <Home size={14} class="text-muted-foreground" />
        </button>
      </div>

      <span class="text-xs text-muted-foreground font-medium">my-project</span>

      <div class="flex items-center gap-1">
        <button
          class="p-1.5 rounded-md hover:bg-muted transition-colors"
          onclick={toggleDarkMode}
        >
          {#if darkMode}
            <Moon size={14} class="text-muted-foreground" />
          {:else}
            <Sun size={14} class="text-muted-foreground" />
          {/if}
        </button>
        <button
          class="p-1.5 rounded-md hover:bg-muted transition-colors"
          onclick={() => rightSidebarOpen = !rightSidebarOpen}
        >
          <PanelRight size={14} class="text-muted-foreground" />
        </button>
      </div>
    </div>
  </div>

  <!-- Main content -->
  <div class="flex h-[420px]">
    <!-- Left sidebar -->
    <div
      class="sidebar-transition bg-sidebar border-r border-border overflow-hidden"
      style="width: {leftSidebarOpen ? '180px' : '0px'}"
    >
      <div class="p-3 w-[180px]">
        <div class="text-[10px] uppercase tracking-widest font-semibold text-muted-foreground mb-2">
          Files
        </div>
        <div class="space-y-0.5">
          {#each flatFileTree as { node, path, depth }}
            <button
              class="flex items-center gap-1.5 w-full text-left py-0.5 px-1 rounded hover:bg-muted/50 transition-colors text-xs text-foreground/80"
              style="padding-left: {depth * 12 + 4}px"
              onclick={() => node.type === 'folder' && toggleFolder(path)}
            >
              {#if node.type === 'folder'}
                {#if expandedFolders.has(path)}
                  <ChevronDown size={12} class="text-muted-foreground shrink-0" />
                  <FolderOpen size={12} class="text-muted-foreground shrink-0" />
                {:else}
                  <ChevronRight size={12} class="text-muted-foreground shrink-0" />
                  <Folder size={12} class="text-muted-foreground shrink-0" />
                {/if}
              {:else}
                <span class="w-3"></span>
                <File size={12} class="text-muted-foreground shrink-0" />
              {/if}
              <span class="truncate">{node.name}</span>
            </button>
          {/each}
        </div>
      </div>
    </div>

    <!-- Chat area -->
    <div class="flex-1 flex flex-col min-w-0">
      <!-- Messages -->
      <div class="flex-1 overflow-y-auto p-4 space-y-4 demo-scrollbar">
        {#each messages as message}
          {#if message.role === 'user'}
            <div class="border-t border-border/50 pt-4">
              <div class="text-sm text-foreground/70 italic">
                {message.content}
              </div>
            </div>
            <div class="border-b border-border/50 pb-0"></div>
          {:else}
            <div class="space-y-3">
              <div class="text-sm text-foreground/90 leading-relaxed">
                {message.content}
              </div>
              {#if message.tools}
                <div class="space-y-2">
                  {#each message.tools as tool}
                    {@const Icon = getToolIcon(tool.type)}
                    <div class="flex items-center justify-between rounded-lg border px-3 h-9 {getToolColor(tool.type)}">
                      <div class="flex items-center gap-2 min-w-0">
                        <Icon size={12} />
                        <span class="text-[10px] font-medium uppercase tracking-wide opacity-70">
                          {tool.type === 'Read' ? 'view' : tool.type === 'Edit' ? 'edit' : 'bash'}
                        </span>
                        <span class="text-[10px] text-muted-foreground truncate">{tool.target}</span>
                      </div>
                      <div class="flex items-center">
                        {#if tool.status === 'completed'}
                          <Check size={12} class="text-green-500" />
                        {:else if tool.status === 'running'}
                          <Loader2 size={12} class="animate-spin" />
                        {/if}
                      </div>
                    </div>
                  {/each}
                </div>
              {/if}
            </div>
          {/if}
        {/each}
      </div>

      <!-- Input area -->
      <div class="border-t border-border p-3">
        <div class="bg-card rounded-xl border border-border shadow-sm">
          <div class="relative">
            <textarea
              bind:value={inputValue}
              placeholder="Ask Claude anything..."
              rows="2"
              class="w-full py-2.5 px-3 pr-12 bg-transparent resize-none outline-none text-sm text-foreground placeholder:text-muted-foreground"
            ></textarea>
            <button class="absolute right-2 top-1/2 -translate-y-1/2 w-8 h-8 rounded-lg bg-foreground text-background flex items-center justify-center hover:opacity-90 transition-opacity">
              <ArrowUp size={16} />
            </button>
          </div>
          <div class="flex items-center gap-2 px-2 pb-1.5 border-t border-border">
            <button class="flex items-center gap-1.5 px-2 py-1 rounded text-[10px] hover:bg-muted transition-colors">
              <div class="flex items-center -space-x-0.5">
                <Circle size={6} class="fill-current" />
                <Circle size={5} class="fill-current opacity-70" />
                <Circle size={4} class="fill-current opacity-40" />
              </div>
              <span>Opus 4.5</span>
            </button>
            <button class="flex items-center gap-1.5 px-2 py-1 rounded text-[10px] hover:bg-muted transition-colors">
              <Shield size={10} />
              <span>Default</span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Right sidebar -->
    <div
      class="sidebar-transition bg-sidebar border-l border-border overflow-hidden"
      style="width: {rightSidebarOpen ? '160px' : '0px'}"
    >
      <div class="p-3 w-[160px] h-full flex flex-col">
        <!-- Todos -->
        <div class="flex-1">
          <div class="text-[10px] uppercase tracking-widest font-semibold text-muted-foreground mb-2">
            Todos
          </div>
          <div class="space-y-1">
            {#each todos as todo}
              <div class="flex items-center gap-2 text-[11px]">
                {#if todo.status === 'done'}
                  <Check size={10} class="text-green-500 shrink-0" />
                {:else if todo.status === 'active'}
                  <Loader2 size={10} class="text-amber-500 animate-spin shrink-0" />
                {:else}
                  <Circle size={10} class="text-muted-foreground shrink-0" />
                {/if}
                <span class="truncate text-foreground/80" class:line-through={todo.status === 'done'} class:opacity-50={todo.status === 'done'}>
                  {todo.text}
                </span>
              </div>
            {/each}
          </div>
        </div>

        <!-- Skills -->
        <div class="pt-3 border-t border-border mt-3">
          <div class="text-[10px] uppercase tracking-widest font-semibold text-muted-foreground mb-2">
            Active Skills
          </div>
          <div class="space-y-1">
            {#each skills as skill}
              <div class="flex items-center gap-2 text-[11px] text-foreground/80">
                <Sparkles size={10} class="text-purple-500 shrink-0" />
                <span class="truncate">{skill.name}</span>
              </div>
            {/each}
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
