import { Application } from '@hotwired/stimulus';
import TurboModalController from './turbo_modal_controller';
import TurboModalContainerController from './turbo_modal_container_controller';
import AlertController from './alert_controller';
import ProjectFormController from './project_form_controller';
import ProjectGuidelinesFormController from './project_guidelines_form_controller';
import AutoDisableFormController from './auto_disable_form_controller';
import MenuSidebarController from './menu_sidebar_controller';

const Stimulus = Application.start();
Stimulus.register('turbo-modal-container', TurboModalContainerController);
Stimulus.register('turbo-modal', TurboModalController);
Stimulus.register('alert', AlertController);
Stimulus.register('project-form', ProjectFormController);
Stimulus.register('project-guidelines-form', ProjectGuidelinesFormController);
Stimulus.register('auto-disable-form', AutoDisableFormController);
Stimulus.register('menu-sidebar', MenuSidebarController);
