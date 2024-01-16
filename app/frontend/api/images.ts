import axios from './index';
import { LoadingInfo, UserRequestType, PostRequest, RequestsInfo } from '@/types';
import * as routes from '@/api/routes';
export const deleteImage = async (id: number) => {
  return axios<LoadingInfo>({ method: 'delete', url: 'k' });
};
