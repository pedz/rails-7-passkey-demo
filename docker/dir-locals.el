;;; My preferred method is to create a project specific set of
;;; configuration variables and not have a .dir-local.el so this is
;;; mostly here just as a reminder.  See
;;; ~/.config/emacs/pedz/project-setups.org for more information.

((nil . ((yari-ri-program-name .   "./docker/compose-exec.sh -T web bundle exec ri")
         (yari-ruby-program-name . "./docker/compose-exec.sh -T web bundle exec ruby"))))
