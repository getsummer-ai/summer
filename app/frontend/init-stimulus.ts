import { Application } from '@hotwired/stimulus';
import TurboModalController from '@/entrypoints/stimulus/turbo_modal_controller';
import AlertController from '@/entrypoints/stimulus/alert_controller';

const Stimulus = Application.start();
Stimulus.register('turbo-modal', TurboModalController);
Stimulus.register('alert', AlertController);
