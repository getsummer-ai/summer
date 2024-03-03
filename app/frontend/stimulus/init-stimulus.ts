import { Application } from '@hotwired/stimulus';
import TurboModalController from './turbo_modal_controller';
import TurboModalContainerController from './turbo_modal_container_controller';
import AlertController from './alert_controller';

const Stimulus = Application.start();
Stimulus.register('turbo-modal-container', TurboModalContainerController);
Stimulus.register('turbo-modal', TurboModalController);
Stimulus.register('alert', AlertController);
