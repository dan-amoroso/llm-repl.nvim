### Why?
I don't enjoy the ghost text completion that most integrations with LLMs use, but the copy-paste workflow with the web ui is too distracting and too much work. I am attempting to find a middle-ground.

### How?
I really enjoy working with repls in the way Conjure and similar plugins enable. The repl interacts with the user via a dedicated buffer where both the executed code and the evaluated results are appended. The plugins also make it easy to run code against the repl from whatever buffer is being edited at any moment. The interaction buffer can then be displayed as the user prefers.

### What?
Primarily, the usage loop I envision is writig a prompt in the current file, visually select it (and optionally a code snippet, the full buffer, possibly the whole set of open files as context) and post it to an LLM. The response to the prompt is then appended to a diffent buffer, but the plugin will give the user ways to easily interact with it (EG: accept the last suggestion)

Secondarily, I would like to get to the point where the interaction looks like a pair programming session.
